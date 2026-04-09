import Foundation

struct DeckGenerationRequest: Codable {
    var showName: String
    var season: Int
    var episode: Int
    var responseSchemaVersion: Int = 2
}
