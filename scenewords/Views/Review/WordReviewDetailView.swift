import SwiftUI

struct WordReviewDetailView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    let initialCardID: UUID
    @State private var selectedCardID: UUID?

    private var cards: [WordCard] {
        appViewModel.reviewCards
    }

    private var currentWord: String? {
        guard let selectedCardID else { return nil }
        return cards.first(where: { $0.id == selectedCardID })?.word
    }

    var body: some View {
        Group {
            if cards.isEmpty {
                ContentUnavailableView(
                    "暂无待复习单词",
                    systemImage: "checkmark.seal",
                    description: Text("当前单词已完成复习。")
                )
            } else {
                WordCardPagerView(
                    cards: cards,
                    selectedCardID: $selectedCardID,
                    onStatusChange: { cardID, status in
                        appViewModel.updateStatus(for: cardID, to: status)
                    },
                    onStarChange: { cardID, isStarred in
                        appViewModel.updateStar(for: cardID, to: isStarred)
                    }
                )
            }
        }
        .navigationTitle(currentWord ?? "复习卡片")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if cards.contains(where: { $0.id == initialCardID }) {
                selectedCardID = initialCardID
            } else {
                selectedCardID = cards.first?.id
            }
        }
    }
}
