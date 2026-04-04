import SwiftUI

struct WordReviewDetailView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    let cardID: UUID

    private var card: WordCard? {
        appViewModel.card(with: cardID)
    }

    var body: some View {
        Group {
            if let card {
                List {
                    Section("单词") {
                        Text(card.word)
                            .font(.title3.weight(.semibold))
                        Text(card.meaning)
                            .font(.body)
                    }

                    Section("例句") {
                        Text(card.exampleSentence)
                    }

                    Section("场景说明") {
                        Text(card.sceneContext)
                    }

                    Section("掌握状态") {
                        Picker("状态", selection: Binding(
                            get: { card.status },
                            set: { newStatus in
                                appViewModel.updateStatus(for: cardID, to: newStatus)
                            }
                        )) {
                            ForEach(WordStatus.allCases) { status in
                                Text(status.displayName).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section("来源") {
                        Text(card.sourceEpisodeText)
                            .foregroundStyle(.secondary)
                    }
                }
                .listStyle(.insetGrouped)
            } else {
                ContentUnavailableView("单词不存在", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(card?.word ?? "单词详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}
