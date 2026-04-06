import Foundation

protocol DeckGenerating {
    func generateDeck(request: DeckGenerationRequest) async throws -> WordDeck
}
