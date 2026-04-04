import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var decks: [WordDeck]

    private let generator: DeckGenerating

    init(
        decks: [WordDeck],
        generator: DeckGenerating
    ) {
        self.decks = decks.sorted { $0.createdAt > $1.createdAt }
        self.generator = generator
    }

    static func makeDefault() -> AppViewModel {
        AppViewModel(decks: MockDeckData.initialDecks, generator: MockDeckGeneratorService())
    }

    var reviewCards: [WordCard] {
        decks
            .flatMap(\.cards)
            .filter { $0.status != .mastered }
            .sorted { lhs, rhs in
                lhs.word.localizedCaseInsensitiveCompare(rhs.word) == .orderedAscending
            }
    }

    func generateDeck(request: DeckGenerationRequest) {
        let newDeck = generator.generateDeck(request: request)
        decks.insert(newDeck, at: 0)
    }

    func card(with id: UUID) -> WordCard? {
        for deck in decks {
            if let card = deck.cards.first(where: { $0.id == id }) {
                return card
            }
        }
        return nil
    }

    func updateStatus(for cardID: UUID, to status: WordStatus) {
        for deckIndex in decks.indices {
            if let cardIndex = decks[deckIndex].cards.firstIndex(where: { $0.id == cardID }) {
                decks[deckIndex].cards[cardIndex].status = status
                return
            }
        }
    }

    func updateStar(for cardID: UUID, to isStarred: Bool) {
        for deckIndex in decks.indices {
            if let cardIndex = decks[deckIndex].cards.firstIndex(where: { $0.id == cardID }) {
                decks[deckIndex].cards[cardIndex].isStarred = isStarred
                return
            }
        }
    }
}
