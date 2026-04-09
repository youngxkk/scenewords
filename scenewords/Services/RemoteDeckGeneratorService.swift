import Foundation

struct RemoteDeckGeneratorService: DeckGenerating {
    private let baseURL: URL
    private let bearerToken: String?
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let pollingIntervalNanoseconds: UInt64
    private let maxPollingAttempts: Int

    init(
        baseURL: URL,
        bearerToken: String? = nil,
        session: URLSession = .shared,
        pollingIntervalNanoseconds: UInt64 = 800_000_000,
        maxPollingAttempts: Int = 40
    ) {
        self.baseURL = baseURL
        self.bearerToken = bearerToken
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        self.pollingIntervalNanoseconds = pollingIntervalNanoseconds
        self.maxPollingAttempts = maxPollingAttempts
    }

    func generateDeck(request: DeckGenerationRequest) async throws -> WordDeck {
        do {
            return try await generateDeckAsyncJob(request: request)
        } catch let error as DeckGeneratorError {
            if case let .server(statusCode, _) = error, statusCode == 404 {
                // Compatibility fallback for older backend deployments.
                return try await generateDeckSync(request: request)
            }
            throw error
        } catch {
            // Compatibility fallback for older backend deployments.
            throw DeckGeneratorError.network(error)
        }
    }

    private func generateDeckAsyncJob(request: DeckGenerationRequest) async throws -> WordDeck {
        let endpoint = baseURL.appending(path: "v1/decks/request")
        let (data, httpResponse) = try await sendPostRequest(to: endpoint, body: request)

        let jobResponse = try decodeJobResponse(data: data, defaultShowName: request.showName, season: request.season, episode: request.episode)
        switch jobResponse.status {
        case "ready":
            guard let deck = jobResponse.deck else {
                throw DeckGeneratorError.invalidResponse
            }
            return deck
        case "pending":
            guard let jobID = jobResponse.jobId, !jobID.isEmpty else {
                throw DeckGeneratorError.invalidResponse
            }
            return try await pollJob(jobID: jobID, fallbackRequest: request)
        case "failed":
            throw DeckGeneratorError.server(statusCode: httpResponse.statusCode, message: jobResponse.error)
        default:
            throw DeckGeneratorError.server(statusCode: httpResponse.statusCode, message: jobResponse.error)
        }
    }

    private func generateDeckSync(request: DeckGenerationRequest) async throws -> WordDeck {
        let endpoint = baseURL.appending(path: "v1/decks/generate")
        let (data, _) = try await sendPostRequest(to: endpoint, body: request)
        let apiResponse = try decoder.decode(DeckGenerationAPIResponse.self, from: data)
        return apiResponse.deck.toWordDeck(defaultShowName: request.showName, season: request.season, episode: request.episode)
    }

    private func sendPostRequest<T: Encodable>(to endpoint: URL, body: T) async throws -> (Data, HTTPURLResponse) {
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        if let bearerToken, !bearerToken.isEmpty {
            urlRequest.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        do {
            urlRequest.httpBody = try encoder.encode(body)
        } catch {
            throw DeckGeneratorError.invalidRequest
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw DeckGeneratorError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DeckGeneratorError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) || httpResponse.statusCode == 202 else {
            let message = parseServerErrorMessage(from: data)
            throw DeckGeneratorError.server(statusCode: httpResponse.statusCode, message: message)
        }

        return (data, httpResponse)
    }

    private func sendGetRequest(to endpoint: URL) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let bearerToken, !bearerToken.isEmpty {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw DeckGeneratorError.network(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw DeckGeneratorError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) || httpResponse.statusCode == 202 else {
            let message = parseServerErrorMessage(from: data)
            throw DeckGeneratorError.server(statusCode: httpResponse.statusCode, message: message)
        }

        return (data, httpResponse)
    }

    private func pollJob(jobID: String, fallbackRequest: DeckGenerationRequest) async throws -> WordDeck {
        let endpoint = baseURL.appending(path: "v1/decks/jobs/\(jobID)")
        for _ in 0..<maxPollingAttempts {
            let (data, httpResponse) = try await sendGetRequest(to: endpoint)
            let response = try decodeJobResponse(
                data: data,
                defaultShowName: fallbackRequest.showName,
                season: fallbackRequest.season,
                episode: fallbackRequest.episode
            )

            switch response.status {
            case "ready":
                if let deck = response.deck {
                    return deck
                }
                throw DeckGeneratorError.invalidResponse
            case "failed":
                throw DeckGeneratorError.server(statusCode: httpResponse.statusCode, message: response.error)
            case "pending":
                try await Task.sleep(nanoseconds: pollingIntervalNanoseconds)
            default:
                throw DeckGeneratorError.invalidResponse
            }
        }

        throw DeckGeneratorError.timeout
    }

    private func decodeJobResponse(data: Data, defaultShowName: String, season: Int, episode: Int) throws -> DeckJobResponseMapped {
        let raw = try decoder.decode(DeckJobResponse.self, from: data)
        let mappedDeck = raw.deck?.toWordDeck(defaultShowName: defaultShowName, season: season, episode: episode)
        return DeckJobResponseMapped(status: raw.status ?? "unknown", jobId: raw.jobId, error: raw.error, deck: mappedDeck)
    }

    private func parseServerErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let error = object["error"] {
            if let message = error as? String {
                return message
            }
            if let errorObject = error as? [String: Any],
               let message = errorObject["message"] as? String {
                return message
            }
        }
        return String(data: data, encoding: .utf8)
    }
}

struct FallbackDeckGeneratorService: DeckGenerating {
    private let primary: DeckGenerating
    private let fallback: DeckGenerating

    init(primary: DeckGenerating, fallback: DeckGenerating) {
        self.primary = primary
        self.fallback = fallback
    }

    func generateDeck(request: DeckGenerationRequest) async throws -> WordDeck {
        do {
            return try await primary.generateDeck(request: request)
        } catch {
            return try await fallback.generateDeck(request: request)
        }
    }
}

enum DeckGeneratorError: LocalizedError {
    case missingConfiguration
    case invalidRequest
    case network(Error)
    case invalidResponse
    case server(statusCode: Int, message: String?)
    case decoding(Error)
    case timeout
    case localDeckNotFound(showName: String, season: Int, episode: Int)

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            return "未配置线上生成服务地址，请先设置 SCENEWORDS_API_BASE_URL。"
        case .invalidRequest:
            return "请求构建失败，请检查输入参数。"
        case .network:
            return "网络异常，请检查网络后重试。"
        case .invalidResponse:
            return "服务返回格式异常。"
        case let .server(statusCode, message):
            if let message, !message.swTrimmed.isEmpty {
                return "服务错误(\(statusCode)): \(message)"
            }
            return "服务错误(\(statusCode))"
        case .decoding:
            return "解析生成结果失败，请稍后重试。"
        case .timeout:
            return "生成超时，请稍后重试。"
        case let .localDeckNotFound(showName, season, episode):
            return "内置剧集仅支持本地 JSON：未找到 \(showName) S\(String(format: "%02d", season))E\(String(format: "%02d", episode))，请先补充本地文件。"
        }
    }
}

private struct DeckJobResponseMapped {
    var status: String
    var jobId: String?
    var error: String?
    var deck: WordDeck?
}

private struct DeckJobResponse: Decodable {
    var status: String?
    var jobId: String?
    var error: String?
    var deck: GeneratedDeck?
}

private struct DeckGenerationAPIResponse: Decodable {
    var deck: GeneratedDeck
}

private struct GeneratedDeck: Decodable {
    var id: UUID?
    var showName: String?
    var season: Int?
    var episode: Int?
    var title: String
    var summary: String
    var cards: [GeneratedCard]

    private enum CodingKeys: String, CodingKey {
        case id
        case deckId
        case showName
        case season
        case episode
        case title
        case summary
        case cards
        case source
        case deckMetadata
    }

    private enum SourceCodingKeys: String, CodingKey {
        case showName
        case seasonNumber
        case episodeNumber
    }

    private enum DeckMetadataCodingKeys: String, CodingKey {
        case title
        case summary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let sourceContainer = try? container.nestedContainer(keyedBy: SourceCodingKeys.self, forKey: .source) {
            id = try container.decodeIfPresent(UUID.self, forKey: .id)
                ?? container.decodeIfPresent(UUID.self, forKey: .deckId)
            showName = try sourceContainer.decodeIfPresent(String.self, forKey: .showName)
            season = try sourceContainer.decodeIfPresent(Int.self, forKey: .seasonNumber)
            episode = try sourceContainer.decodeIfPresent(Int.self, forKey: .episodeNumber)

            let metadataContainer = try container.nestedContainer(keyedBy: DeckMetadataCodingKeys.self, forKey: .deckMetadata)
            title = try metadataContainer.decode(String.self, forKey: .title)
            if let localizedSummary = try? metadataContainer.decode([String: String].self, forKey: .summary) {
                summary = localizedSummary["zh-CN"]
                    ?? localizedSummary["zh"]
                    ?? localizedSummary["en"]
                    ?? localizedSummary.values.first
                    ?? ""
            } else {
                summary = try metadataContainer.decode(String.self, forKey: .summary)
            }
            cards = try container.decodeIfPresent([GeneratedCard].self, forKey: .cards) ?? []
        } else {
            id = try container.decodeIfPresent(UUID.self, forKey: .id)
            showName = try container.decodeIfPresent(String.self, forKey: .showName)
            season = try container.decodeIfPresent(Int.self, forKey: .season)
            episode = try container.decodeIfPresent(Int.self, forKey: .episode)
            title = try container.decode(String.self, forKey: .title)
            summary = try container.decode(String.self, forKey: .summary)
            cards = try container.decodeIfPresent([GeneratedCard].self, forKey: .cards) ?? []
        }
    }

    func toWordDeck(defaultShowName: String, season: Int, episode: Int) -> WordDeck {
        let trimmedShowName = showName?.swTrimmed ?? ""
        let resolvedShowName = trimmedShowName.isEmpty ? defaultShowName : trimmedShowName
        let resolvedSeason = self.season ?? season
        let resolvedEpisode = self.episode ?? episode

        let mappedCards = cards.map { card in
            card.toWordCard(showName: resolvedShowName, season: resolvedSeason, episode: resolvedEpisode)
        }

        return WordDeck(
            id: id ?? UUID(),
            showName: resolvedShowName,
            season: resolvedSeason,
            episode: resolvedEpisode,
            title: title,
            summary: summary,
            cards: mappedCards,
            createdAt: Date()
        )
    }
}

private struct GeneratedCard: Decodable {
    var id: UUID?
    var word: String
    var phonetic: String?
    var pos: String?
    var meaning: String
    var phrase: String?
    var previousSentence: String?
    var exampleSentence: String
    var exampleSentenceTranslation: String?
    var nextSentence: String?
    var sceneContext: String
    var usageTip: String?
    var alternatives: [String]?
    var difficulty: WordDifficulty?
    var volumeTier: WordVolumeTier?
    var status: WordStatus?
    var isStarred: Bool?
    var sourceShowName: String?
    var seasonNumber: Int?
    var episodeNumber: Int?

    private enum CodingKeys: String, CodingKey {
        case id
        case cardId
        case word
        case phonetic
        case pos
        case meaning
        case phrase
        case previousSentence
        case exampleSentence
        case exampleSentenceTranslation
        case nextSentence
        case sceneContext
        case usageTip
        case alternatives
        case difficulty
        case volumeTier
        case status
        case isStarred
        case sourceShowName
        case season
        case episode
        case term
        case sourceContext
        case localizedContent
        case learningMetadata
    }

    private enum TermCodingKeys: String, CodingKey {
        case text
        case phonetic
        case partOfSpeech
    }

    private enum SourceContextCodingKeys: String, CodingKey {
        case previousLine
        case targetLine
        case nextLine
    }

    private enum LearningMetadataCodingKeys: String, CodingKey {
        case difficultyLevel
        case volumeTier
        case status
        case isStarred
        case sourceShowName
        case seasonNumber
        case episodeNumber
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let termContainer = try? container.nestedContainer(keyedBy: TermCodingKeys.self, forKey: .term) {
            id = try container.decodeIfPresent(UUID.self, forKey: .id)
                ?? container.decodeIfPresent(UUID.self, forKey: .cardId)
            word = try termContainer.decode(String.self, forKey: .text)
            phonetic = try termContainer.decodeIfPresent(String.self, forKey: .phonetic)
            pos = try termContainer.decodeIfPresent(String.self, forKey: .partOfSpeech)

            let sourceContextContainer = try container.nestedContainer(keyedBy: SourceContextCodingKeys.self, forKey: .sourceContext)
            previousSentence = try sourceContextContainer.decodeIfPresent(String.self, forKey: .previousLine)
            exampleSentence = try sourceContextContainer.decode(String.self, forKey: .targetLine)
            nextSentence = try sourceContextContainer.decodeIfPresent(String.self, forKey: .nextLine)

            let localizedMap = try container.decodeIfPresent([String: RemoteLocalizedCardContent].self, forKey: .localizedContent) ?? [:]
            let localized = localizedMap["zh-CN"]
                ?? localizedMap["zh"]
                ?? localizedMap["en"]
                ?? localizedMap.values.first

            meaning = localized?.definitions.first ?? ""
            phrase = localized?.corePhrase
            exampleSentenceTranslation = localized?.exampleTranslation
            sceneContext = localized?.sceneNotes ?? ""
            usageTip = localized?.usageNotes
            alternatives = try container.decodeIfPresent([String].self, forKey: .alternatives)

            let learningMetadataContainer = try container.nestedContainer(keyedBy: LearningMetadataCodingKeys.self, forKey: .learningMetadata)
            difficulty = try learningMetadataContainer.decodeIfPresent(WordDifficulty.self, forKey: .difficultyLevel)
            volumeTier = try learningMetadataContainer.decodeIfPresent(WordVolumeTier.self, forKey: .volumeTier)
            status = try learningMetadataContainer.decodeIfPresent(WordStatus.self, forKey: .status)
            isStarred = try learningMetadataContainer.decodeIfPresent(Bool.self, forKey: .isStarred)
            sourceShowName = try learningMetadataContainer.decodeIfPresent(String.self, forKey: .sourceShowName)
            seasonNumber = try learningMetadataContainer.decodeIfPresent(Int.self, forKey: .seasonNumber)
            episodeNumber = try learningMetadataContainer.decodeIfPresent(Int.self, forKey: .episodeNumber)
        } else {
            id = try container.decodeIfPresent(UUID.self, forKey: .id)
            word = try container.decode(String.self, forKey: .word)
            phonetic = try container.decodeIfPresent(String.self, forKey: .phonetic)
            pos = try container.decodeIfPresent(String.self, forKey: .pos)
            meaning = try container.decode(String.self, forKey: .meaning)
            phrase = try container.decodeIfPresent(String.self, forKey: .phrase)
            previousSentence = try container.decodeIfPresent(String.self, forKey: .previousSentence)
            exampleSentence = try container.decode(String.self, forKey: .exampleSentence)
            exampleSentenceTranslation = try container.decodeIfPresent(String.self, forKey: .exampleSentenceTranslation)
            nextSentence = try container.decodeIfPresent(String.self, forKey: .nextSentence)
            sceneContext = try container.decode(String.self, forKey: .sceneContext)
            usageTip = try container.decodeIfPresent(String.self, forKey: .usageTip)
            alternatives = try container.decodeIfPresent([String].self, forKey: .alternatives)
            difficulty = try container.decodeIfPresent(WordDifficulty.self, forKey: .difficulty)
            volumeTier = try container.decodeIfPresent(WordVolumeTier.self, forKey: .volumeTier)
            status = try container.decodeIfPresent(WordStatus.self, forKey: .status)
            isStarred = try container.decodeIfPresent(Bool.self, forKey: .isStarred)
            sourceShowName = try container.decodeIfPresent(String.self, forKey: .sourceShowName)
            seasonNumber = try container.decodeIfPresent(Int.self, forKey: .season)
            episodeNumber = try container.decodeIfPresent(Int.self, forKey: .episode)
        }
    }

    func toWordCard(showName: String, season: Int, episode: Int) -> WordCard {
        let normalizedDifficulty = difficulty ?? .medium

        return WordCard(
            id: id ?? UUID(),
            word: word,
            phonetic: phonetic,
            pos: pos,
            meaning: meaning,
            phrase: phrase,
            previousSentence: previousSentence,
            exampleSentence: exampleSentence,
            exampleSentenceTranslation: exampleSentenceTranslation,
            nextSentence: nextSentence,
            sceneContext: sceneContext,
            usageTip: usageTip,
            alternatives: alternatives ?? [],
            difficulty: normalizedDifficulty,
            volumeTier: volumeTier,
            status: status ?? .new,
            isStarred: isStarred ?? false,
            sourceShowName: sourceShowName ?? showName,
            season: seasonNumber ?? season,
            episode: episodeNumber ?? episode
        )
    }
}

private struct RemoteLocalizedCardContent: Decodable {
    var definitions: [String]
    var corePhrase: String?
    var exampleTranslation: String?
    var sceneNotes: String
    var usageNotes: String?
}
