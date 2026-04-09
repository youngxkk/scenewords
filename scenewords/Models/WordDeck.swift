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

    private enum CodingKeys: String, CodingKey {
        case id
        case deckId
        case showName
        case season
        case episode
        case title
        case summary
        case createdAt
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
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(UUID.self, forKey: .id)
            ?? container.decode(UUID.self, forKey: .deckId)

        if let sourceContainer = try? container.nestedContainer(keyedBy: SourceCodingKeys.self, forKey: .source) {
            showName = try sourceContainer.decode(String.self, forKey: .showName)
            season = try sourceContainer.decode(Int.self, forKey: .seasonNumber)
            episode = try sourceContainer.decode(Int.self, forKey: .episodeNumber)

            let metadataContainer = try container.nestedContainer(keyedBy: DeckMetadataCodingKeys.self, forKey: .deckMetadata)
            title = try metadataContainer.decode(String.self, forKey: .title)
            createdAt = try metadataContainer.decode(Date.self, forKey: .createdAt)

            if let localizedSummary = try? metadataContainer.decode([String: String].self, forKey: .summary) {
                summary = localizedSummary["zh-CN"]
                    ?? localizedSummary["zh"]
                    ?? localizedSummary["en"]
                    ?? localizedSummary.values.first
                    ?? ""
            } else {
                summary = try metadataContainer.decode(String.self, forKey: .summary)
            }
        } else {
            showName = try container.decode(String.self, forKey: .showName)
            season = try container.decode(Int.self, forKey: .season)
            episode = try container.decode(Int.self, forKey: .episode)
            title = try container.decode(String.self, forKey: .title)
            summary = try container.decode(String.self, forKey: .summary)
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }

        cards = try container.decodeIfPresent([WordCard].self, forKey: .cards) ?? []
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(showName, forKey: .showName)
        try container.encode(season, forKey: .season)
        try container.encode(episode, forKey: .episode)
        try container.encode(title, forKey: .title)
        try container.encode(summary, forKey: .summary)
        try container.encode(cards, forKey: .cards)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

private extension Int {
    var twoDigits: String {
        String(format: "%02d", self)
    }
}
