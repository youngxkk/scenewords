import Foundation

struct WordDeck: Identifiable, Codable, Hashable {
    let id: UUID
    var showName: String
    var season: Int
    var episode: Int
    var title: String
    var summary: String
    var cards: [WordCard]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        showName: String,
        season: Int,
        episode: Int,
        title: String,
        summary: String,
        cards: [WordCard],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.showName = showName
        self.season = season
        self.episode = episode
        self.title = title
        self.summary = summary
        self.cards = cards
        self.createdAt = createdAt
    }

    var episodeCode: String {
        "S\(season.twoDigits)E\(episode.twoDigits)"
    }

    var cardCountText: String {
        "\(cards.count) 张卡片"
    }
}

private extension Int {
    var twoDigits: String {
        String(format: "%02d", self)
    }
}
