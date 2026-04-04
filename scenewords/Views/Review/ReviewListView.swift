import SwiftUI

struct ReviewListView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        Group {
            if appViewModel.reviewCards.isEmpty {
                ContentUnavailableView(
                    "暂无待复习单词",
                    systemImage: "checkmark.seal",
                    description: Text("已掌握的词会自动从待复习列表移除。")
                )
            } else {
                List(appViewModel.reviewCards) { card in
                    NavigationLink(value: card.id) {
                        ReviewRowView(card: card)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("复习")
        .navigationDestination(for: UUID.self) { cardID in
            WordReviewDetailView(initialCardID: cardID)
        }
    }
}

private struct ReviewRowView: View {
    let card: WordCard

    var body: some View {
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

            Text(card.sourceEpisodeText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        ReviewListView()
            .environmentObject(AppViewModel.makeDefault())
    }
}
