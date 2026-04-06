import Foundation
import Combine

@MainActor
final class AppViewModel: ObservableObject {
    @Published private(set) var decks: [WordDeck]
    @Published private(set) var generationSourceLabel: String

    private let generator: DeckGenerating
    private let progressStore: LearningProgressStore

    init(
        decks: [WordDeck],
        generator: DeckGenerating,
        generationSourceLabel: String,
        progressStore: LearningProgressStore
    ) {
        self.decks = decks.sorted { $0.createdAt > $1.createdAt }
        self.generator = generator
        self.generationSourceLabel = generationSourceLabel
        self.progressStore = progressStore
        applyPersistedProgress()
    }

    static func makeDefault() -> AppViewModel {
        let mockGenerator = MockDeckGeneratorService()
        let config = AppConfiguration.current()
        let localRepository = LocalJSONDeckRepository()
        let localDecks = localRepository.loadAllDecks()

        let fallbackGenerator: DeckGenerating
        let initialDecks: [WordDeck]
        let sourceLabel: String

        if let apiBaseURL = config.apiBaseURL {
            fallbackGenerator = RemoteDeckGeneratorService(
                baseURL: apiBaseURL,
                bearerToken: config.apiToken
            )
            initialDecks = localDecks
            sourceLabel = "本地 JSON 优先（线上兜底）"
        } else {
            fallbackGenerator = mockGenerator
            initialDecks = localDecks.isEmpty ? MockDeckData.initialDecks : localDecks
            sourceLabel = "本地 JSON 优先（Mock 兜底）"
        }

        let generator = LocalFirstDeckGeneratorService(
            localRepository: localRepository,
            fallback: fallbackGenerator
        )

        return AppViewModel(
            decks: initialDecks,
            generator: generator,
            generationSourceLabel: sourceLabel,
            progressStore: LearningProgressStore()
        )
    }

    var reviewCards: [WordCard] {
        let now = Date()
        var dueCardsByKey: [String: WordCard] = [:]

        for deck in decks {
            for card in deck.cards {
                guard isDueForReview(card, now: now) else { continue }
                if dueCardsByKey[card.progressKey] == nil {
                    dueCardsByKey[card.progressKey] = card
                }
            }
        }

        return dueCardsByKey.values.sorted { lhs, rhs in
            let leftDue = reviewProgress(for: lhs).dueAt
            let rightDue = reviewProgress(for: rhs).dueAt
            if leftDue != rightDue {
                return leftDue < rightDue
            }
            return lhs.word.localizedCaseInsensitiveCompare(rhs.word) == .orderedAscending
        }
    }

    func generateDeck(request: DeckGenerationRequest) async throws {
        let newDeck = try await generator.generateDeck(request: request)
        decks.insert(applyingPersistedProgress(to: newDeck), at: 0)
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
        guard let selectedCard = card(with: cardID) else { return }
        let key = selectedCard.progressKey
        let oldProgress = reviewProgress(for: selectedCard)
        let newProgress = nextProgress(from: oldProgress, status: status, now: Date())

        updateCards(matchingProgressKey: key) { card in
            card.status = newProgress.status
            card.isStarred = newProgress.isStarred
        }

        progressStore.upsert(newProgress, for: key)
    }

    func updateStar(for cardID: UUID, to isStarred: Bool) {
        guard let selectedCard = card(with: cardID) else { return }
        let key = selectedCard.progressKey
        var progress = reviewProgress(for: selectedCard)
        progress.isStarred = isStarred

        updateCards(matchingProgressKey: key) { card in
            card.isStarred = isStarred
        }

        progressStore.upsert(progress, for: key)
    }

    func localDecks(for show: FeaturedShow) -> [WordDeck] {
        decks
            .filter { show.matches(showName: $0.showName) }
            .sorted {
                if $0.season == $1.season {
                    return $0.episode < $1.episode
                }
                return $0.season < $1.season
            }
    }

    private func applyPersistedProgress() {
        decks = decks.map(applyingPersistedProgress(to:))
    }

    private func applyingPersistedProgress(to deck: WordDeck) -> WordDeck {
        var deck = deck
        deck.cards = deck.cards.map { card in
            guard let progress = progressStore.progress(for: card.progressKey) else {
                return card
            }

            var updatedCard = card
            updatedCard.status = progress.status
            updatedCard.isStarred = progress.isStarred
            return updatedCard
        }
        return deck
    }

    private func updateCards(matchingProgressKey key: String, mutate: (inout WordCard) -> Void) {
        for deckIndex in decks.indices {
            for cardIndex in decks[deckIndex].cards.indices {
                guard decks[deckIndex].cards[cardIndex].progressKey == key else { continue }
                mutate(&decks[deckIndex].cards[cardIndex])
            }
        }
    }

    private func reviewProgress(for card: WordCard) -> LearningProgress {
        progressStore.progress(for: card.progressKey) ?? defaultProgress(for: card)
    }

    private func defaultProgress(for card: WordCard) -> LearningProgress {
        let now = Date()
        switch card.status {
        case .new:
            return LearningProgress(
                status: .new,
                isStarred: card.isStarred,
                dueAt: now,
                lastReviewedAt: nil,
                intervalDays: 0
            )
        case .learning:
            return LearningProgress(
                status: .learning,
                isStarred: card.isStarred,
                dueAt: now,
                lastReviewedAt: nil,
                intervalDays: 1
            )
        case .mastered:
            return LearningProgress(
                status: .mastered,
                isStarred: card.isStarred,
                dueAt: Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now,
                lastReviewedAt: nil,
                intervalDays: 7
            )
        }
    }

    private func isDueForReview(_ card: WordCard, now: Date) -> Bool {
        reviewProgress(for: card).dueAt <= now
    }

    private func nextProgress(from old: LearningProgress, status: WordStatus, now: Date) -> LearningProgress {
        var progress = old
        progress.status = status
        progress.lastReviewedAt = now

        switch status {
        case .new:
            progress.intervalDays = 0
            progress.dueAt = now
        case .learning:
            progress.intervalDays = 1
            progress.dueAt = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
        case .mastered:
            let baseInterval = max(old.intervalDays, 2)
            let nextInterval = min(baseInterval * 2, 60)
            progress.intervalDays = nextInterval
            progress.dueAt = Calendar.current.date(byAdding: .day, value: nextInterval, to: now) ?? now
        }

        return progress
    }
}
