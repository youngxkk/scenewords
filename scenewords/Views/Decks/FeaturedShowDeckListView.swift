import SwiftUI

struct FeaturedShowDeckListView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    let show: FeaturedShow
    @State private var selectedSeason: Int?
    @State private var selectedEpisode: Int?
    @State private var selectedCardID: UUID?

    var body: some View {
        Group {
            if showDecks.isEmpty {
                EmptyStateView(
                    icon: "film.stack",
                    title: "暂无本地卡组",
                    message: "\(show.displayName) 还没有可用的本地 JSON 集数。补充对应季文件后即可显示。",
                    actionTitle: "知道了"
                ) {}
            } else if filteredCards.isEmpty {
                ContentUnavailableView(
                    "暂无对应词卡",
                    systemImage: "text.word.spacing",
                    description: Text("当前筛选条件下没有词卡，请切换季或集。")
                )
            } else {
                WordCardPagerView(
                    cards: filteredCards,
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
        .navigationTitle(show.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    seasonMenu
                    episodeMenu
                }
            }
        }
        .onChange(of: selectedSeason) { _, _ in
            selectedEpisode = nil
            selectedCardID = nil
        }
        .onChange(of: selectedEpisode) { _, _ in
            selectedCardID = nil
        }
        .onAppear {
            if selectedSeason == nil, let firstSeason = showDecks.first?.season {
                // If there is only one unique season in local decks, pre-select it
                let uniqueSeasons = Set(showDecks.map(\.season))
                if uniqueSeasons.count == 1 {
                    selectedSeason = firstSeason
                }
            }
        }
    }

    private var showDecks: [WordDeck] {
        appViewModel.localDecks(for: show)
    }

    private var seasonOptions: [Int] {
        Array(1...show.seasonCount)
    }

    private var episodeOptions: [Int] {
        guard let selectedSeason else { return [] }
        let episodes = Set(
            showDecks
                .filter { $0.season == selectedSeason }
                .map(\.episode)
        )
        return episodes.sorted()
    }

    private var filteredDecks: [WordDeck] {
        showDecks.filter { deck in
            if let selectedSeason, deck.season != selectedSeason {
                return false
            }
            if let selectedEpisode, deck.episode != selectedEpisode {
                return false
            }
            return true
        }
    }

    private var filteredCards: [WordCard] {
        filteredDecks.flatMap(\.cards)
    }

    private var seasonTitle: String {
        guard let selectedSeason else { return "S: All" }
        return "S\(selectedSeason)"
    }

    private var episodeTitle: String {
        guard let selectedEpisode else { return "E: All" }
        return "E\(selectedEpisode)"
    }

    private var seasonMenu: some View {
        Menu {
            Button("All") {
                selectedSeason = nil
            }

            ForEach(seasonOptions, id: \.self) { season in
                Button("\(season)") {
                    selectedSeason = season
                }
            }
        } label: {
            selectorLabel(title: seasonTitle)
        }
    }

    private var episodeMenu: some View {
        Menu {
            Button("All") {
                selectedEpisode = nil
            }

            ForEach(episodeOptions, id: \.self) { episode in
                Button("\(episode)") {
                    selectedEpisode = episode
                }
            }
        } label: {
            selectorLabel(title: episodeTitle)
        }
        .disabled(selectedSeason == nil)
        .opacity(selectedSeason == nil ? 0.6 : 1)
    }

    private func selectorLabel(title: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.footnote.weight(.semibold))
            Image(systemName: "chevron.down")
                .font(.footnote.weight(.semibold))
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
    }
}

#Preview {
    NavigationStack {
        FeaturedShowDeckListView(show: FeaturedShow.supported.first!)
            .environmentObject(AppViewModel.makeDefault())
    }
}
