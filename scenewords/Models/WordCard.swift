import Foundation

enum WordStatus: String, Codable, CaseIterable, Identifiable {
    case new
    case learning
    case mastered

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .new: return "new"
        case .learning: return "learning"
        case .mastered: return "mastered"
        }
    }
}

enum WordDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
}

enum WordVolumeTier: String, Codable, CaseIterable {
    case low
    case medium
    case high

    static func from(difficulty: WordDifficulty) -> WordVolumeTier {
        switch difficulty {
        case .easy: return .low
        case .medium: return .medium
        case .hard: return .high
        }
    }
}

struct WordCard: Identifiable, Codable, Hashable {
    let id: UUID
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
    var alternatives: [String]
    var difficulty: WordDifficulty
    // Internal-only tag for future per-user vocabulary volume strategy.
    var volumeTier: WordVolumeTier
    var status: WordStatus
    var isStarred: Bool
    var sourceShowName: String
    var season: Int
    var episode: Int

    private enum CodingKeys: String, CodingKey {
        case id
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
    }

    init(
        id: UUID = UUID(),
        word: String,
        phonetic: String? = nil,
        pos: String? = nil,
        meaning: String,
        phrase: String? = nil,
        previousSentence: String? = nil,
        exampleSentence: String,
        exampleSentenceTranslation: String? = nil,
        nextSentence: String? = nil,
        sceneContext: String,
        usageTip: String? = nil,
        alternatives: [String] = [],
        difficulty: WordDifficulty,
        volumeTier: WordVolumeTier? = nil,
        status: WordStatus = .new,
        isStarred: Bool = false,
        sourceShowName: String,
        season: Int,
        episode: Int
    ) {
        self.id = id
        self.word = word
        self.phonetic = phonetic
        self.pos = pos
        self.meaning = meaning
        self.phrase = phrase
        self.previousSentence = previousSentence
        self.exampleSentence = exampleSentence
        self.exampleSentenceTranslation = exampleSentenceTranslation
        self.nextSentence = nextSentence
        self.sceneContext = sceneContext
        self.usageTip = usageTip
        self.alternatives = alternatives
        self.difficulty = difficulty
        self.volumeTier = volumeTier ?? WordVolumeTier.from(difficulty: difficulty)
        self.status = status
        self.isStarred = isStarred
        self.sourceShowName = sourceShowName
        self.season = season
        self.episode = episode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
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
        alternatives = try container.decodeIfPresent([String].self, forKey: .alternatives) ?? []
        difficulty = try container.decode(WordDifficulty.self, forKey: .difficulty)
        volumeTier = try container.decodeIfPresent(WordVolumeTier.self, forKey: .volumeTier) ?? WordVolumeTier.from(difficulty: difficulty)
        status = try container.decodeIfPresent(WordStatus.self, forKey: .status) ?? .new
        isStarred = try container.decodeIfPresent(Bool.self, forKey: .isStarred) ?? false
        sourceShowName = try container.decode(String.self, forKey: .sourceShowName)
        season = try container.decode(Int.self, forKey: .season)
        episode = try container.decode(Int.self, forKey: .episode)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(word, forKey: .word)
        try container.encodeIfPresent(phonetic, forKey: .phonetic)
        try container.encodeIfPresent(pos, forKey: .pos)
        try container.encode(meaning, forKey: .meaning)
        try container.encodeIfPresent(phrase, forKey: .phrase)
        try container.encodeIfPresent(previousSentence, forKey: .previousSentence)
        try container.encode(exampleSentence, forKey: .exampleSentence)
        try container.encodeIfPresent(exampleSentenceTranslation, forKey: .exampleSentenceTranslation)
        try container.encodeIfPresent(nextSentence, forKey: .nextSentence)
        try container.encode(sceneContext, forKey: .sceneContext)
        try container.encodeIfPresent(usageTip, forKey: .usageTip)
        try container.encode(alternatives, forKey: .alternatives)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(volumeTier, forKey: .volumeTier)
        try container.encode(status, forKey: .status)
        try container.encode(isStarred, forKey: .isStarred)
        try container.encode(sourceShowName, forKey: .sourceShowName)
        try container.encode(season, forKey: .season)
        try container.encode(episode, forKey: .episode)
    }

    var sourceEpisodeText: String {
        "\(sourceShowName) S\(season.twoDigits)E\(episode.twoDigits)"
    }

    var progressKey: String {
        [
            sourceShowName.swProgressNormalized,
            "s\(season)e\(episode)",
            word.swProgressNormalized,
            exampleSentence.swProgressNormalized
        ]
        .joined(separator: "|")
    }
}

private extension Int {
    var twoDigits: String {
        String(format: "%02d", self)
    }
}

private extension String {
    var swProgressNormalized: String {
        swTrimmed
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
