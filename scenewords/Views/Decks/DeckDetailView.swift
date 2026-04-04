import SwiftUI

struct DeckDetailView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    private let deckID: UUID

    init(deck: WordDeck) {
        self.deckID = deck.id
    }

    private var deck: WordDeck? {
        appViewModel.decks.first { $0.id == deckID }
    }

    var body: some View {
        Group {
            if let deck {
                List(deck.cards) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(card.word)
                                .font(.headline)
                            Spacer()
                            Text(card.status.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Text(card.meaning)
                            .font(.subheadline)

                        Text(card.exampleSentence)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
            } else {
                ContentUnavailableView("卡组不存在", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(deck?.episodeCode ?? "卡组详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
