import Foundation

protocol DeckGenerating {
    func generateDeck(request: DeckGenerationRequest) -> WordDeck
}
