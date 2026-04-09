import SwiftUI

struct ReviewListView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        Group {
            if appViewModel.reviewCards.isEmpty {
                ContentUnavailableView(
                    "暂无待复习单词",
                    systemImage: "checkmark.seal",
                    description: Text("当前没有到期词卡，稍后会按复习计划自动出现。")
                )
            } else {
                List(appViewModel.reviewCards) { card in
                    NavigationLink(value: card.id) {
                        ReviewRowView(card: card)
                    }
                }
                .swGroupedListStyle()
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

struct ReviewListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReviewListView()
                .environmentObject(AppViewModel.makeDefault())
        }
    }
}
