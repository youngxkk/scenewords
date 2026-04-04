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

struct WordCard: Identifiable, Codable, Hashable {
    let id: UUID
    var word: String
    var meaning: String
    var exampleSentence: String
    var sceneContext: String
    var difficulty: WordDifficulty
    var status: WordStatus
    var sourceShowName: String
    var season: Int
    var episode: Int

    init(
        id: UUID = UUID(),
        word: String,
        meaning: String,
        exampleSentence: String,
        sceneContext: String,
        difficulty: WordDifficulty,
        status: WordStatus = .new,
        sourceShowName: String,
        season: Int,
        episode: Int
    ) {
        self.id = id
        self.word = word
        self.meaning = meaning
        self.exampleSentence = exampleSentence
        self.sceneContext = sceneContext
        self.difficulty = difficulty
        self.status = status
        self.sourceShowName = sourceShowName
        self.season = season
        self.episode = episode
    }

    var sourceEpisodeText: String {
        "\(sourceShowName) S\(season.twoDigits)E\(episode.twoDigits)"
    }
}

private extension Int {
    var twoDigits: String {
        String(format: "%02d", self)
    }
}
