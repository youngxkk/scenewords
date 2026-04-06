import Foundation

struct LocalSeasonDeckRecord {
    let showID: String
    let showName: String
    let season: Int
    let decks: [WordDeck]
}

final class LocalJSONDeckRepository {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main) {
        self.bundle = bundle
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func loadAllDecks() -> [WordDeck] {
        var seenDeckIDs = Set<UUID>()

        return loadSeasonRecords()
            .flatMap(\.decks)
            .filter { deck in
                seenDeckIDs.insert(deck.id).inserted
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func loadDeck(showName: String, season: Int, episode: Int) -> WordDeck? {
        let requestedShowID = FeaturedShow.resolveShowID(from: showName)
        let requestedShowName = normalizedShowName(showName)

        for record in loadSeasonRecords() where record.season == season {
            let matchedByID = requestedShowID.map { $0 == record.showID } ?? false
            let matchedByName = normalizedShowName(record.showName) == requestedShowName
            guard matchedByID || matchedByName else { continue }

            if let deck = record.decks.first(where: { $0.season == season && $0.episode == episode }) {
                return deck
            }
        }

        return nil
    }

    private func loadSeasonRecords() -> [LocalSeasonDeckRecord] {
        candidateFileURLs().compactMap { url in
            guard let data = try? Data(contentsOf: url),
                  let raw = try? decoder.decode(LocalSeasonDeckFile.self, from: data) else {
                return nil
            }

            let parsedFilename = parseFileName(url.lastPathComponent)
            let rawShowID = raw.showId?.swTrimmed
            let showID = (rawShowID?.isEmpty == false ? rawShowID : parsedFilename.showID) ?? "unknown"
            let showName = raw.showName?.swTrimmed.isEmpty == false
                ? (raw.showName ?? showID)
                : (raw.decks.first?.showName ?? showID)
            let season = raw.season
                ?? raw.decks.first?.season
                ?? parsedFilename.season
                ?? 1

            return LocalSeasonDeckRecord(showID: showID, showName: showName, season: season, decks: raw.decks)
        }
    }

    private func candidateFileURLs() -> [URL] {
        var allURLs = Set<URL>()

        addURLs(bundle.urls(forResourcesWithExtension: "json", subdirectory: nil), into: &allURLs)
        addURLs(bundle.urls(forResourcesWithExtension: "json", subdirectory: "Resources/Shows"), into: &allURLs)
        addURLs(bundle.urls(forResourcesWithExtension: "json", subdirectory: "Shows"), into: &allURLs)

        if let resourceRoot = bundle.resourceURL {
            addDirectoryContentsJSON(from: resourceRoot, into: &allURLs)
            let resourceShows = resourceRoot.appendingPathComponent("Resources/Shows", isDirectory: true)
            let shows = resourceRoot.appendingPathComponent("Shows", isDirectory: true)
            addDirectoryContentsJSON(from: resourceShows, into: &allURLs)
            addDirectoryContentsJSON(from: shows, into: &allURLs)
        }

#if DEBUG
        let cwd = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let debugShows = cwd.appendingPathComponent("scenewords/Resources/Shows", isDirectory: true)
        addDirectoryContentsJSON(from: debugShows, into: &allURLs)
#endif

        return allURLs.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private func addURLs(_ urls: [URL]?, into set: inout Set<URL>) {
        guard let urls else { return }
        for url in urls where url.pathExtension.lowercased() == "json" {
            set.insert(url)
        }
    }

    private func addDirectoryContentsJSON(from directoryURL: URL, into set: inout Set<URL>) {
        guard let urls = try? FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return
        }

        for url in urls where url.pathExtension.lowercased() == "json" {
            set.insert(url)
        }
    }

    private func parseFileName(_ fileName: String) -> (showID: String?, season: Int?) {
        let baseName = (fileName as NSString).deletingPathExtension
        let parts = baseName.split(separator: "_")
        guard let seasonPart = parts.last, seasonPart.hasPrefix("s") else {
            return (baseName, nil)
        }

        let seasonDigits = seasonPart.dropFirst()
        let season = Int(seasonDigits)
        let showID = parts.dropLast().joined(separator: "_")
        return (showID.isEmpty ? nil : showID, season)
    }

    private func normalizedShowName(_ value: String) -> String {
        value
            .swTrimmed
            .lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
    }
}

private struct LocalSeasonDeckFile: Decodable {
    let schemaVersion: Int?
    let showId: String?
    let showName: String?
    let season: Int?
    let decks: [WordDeck]

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case showId
        case showName
        case season
        case decks
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion)
        showId = try container.decodeIfPresent(String.self, forKey: .showId)
        showName = try container.decodeIfPresent(String.self, forKey: .showName)
        season = try container.decodeIfPresent(Int.self, forKey: .season)
        decks = try container.decodeIfPresent([WordDeck].self, forKey: .decks) ?? []
    }
}
