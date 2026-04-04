import SwiftUI

struct DeckListView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var showGeneratePage = false

    var body: some View {
        Group {
            if appViewModel.decks.isEmpty {
                EmptyStateView(
                    icon: "sparkles.rectangle.stack",
                    title: "还没有词卡组",
                    message: "从第一集开始吧，输入美剧和集数即可生成专属词卡。",
                    actionTitle: "生成第一组"
                ) {
                    showGeneratePage = true
                }
            } else {
                List(appViewModel.decks) { deck in
                    NavigationLink(value: deck) {
                        DeckRowView(deck: deck)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("SceneWords")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showGeneratePage = true
                } label: {
                    Label("对话/生成", systemImage: "plus.bubble")
                }
            }
        }
        .navigationDestination(for: WordDeck.self) { deck in
            DeckDetailView(deck: deck)
        }
        .navigationDestination(isPresented: $showGeneratePage) {
            GenerateDeckView()
        }
    }
}

private struct DeckRowView: View {
    let deck: WordDeck

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(deck.showName)
                    .font(.headline)
                Spacer()
                Text(deck.episodeCode)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(deck.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text(deck.cardCountText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        DeckListView()
            .environmentObject(AppViewModel.makeDefault())
    }
}
