import SwiftUI

struct DeckDetailView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    private let deckID: UUID
    @State private var selectedCardID: UUID?

    init(deck: WordDeck) {
        self.deckID = deck.id
    }

    private var deck: WordDeck? {
        appViewModel.decks.first { $0.id == deckID }
    }

    var body: some View {
        Group {
            if let deck {
                WordCardPagerView(
                    cards: deck.cards,
                    selectedCardID: $selectedCardID,
                    onStatusChange: { cardID, status in
                        appViewModel.updateStatus(for: cardID, to: status)
                    },
                    onStarChange: { cardID, isStarred in
                        appViewModel.updateStar(for: cardID, to: isStarred)
                    }
                )
            } else {
                ContentUnavailableView("卡组不存在", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(deck.map { "\($0.showName) \($0.episodeCode)" } ?? "卡组详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
