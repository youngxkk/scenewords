import Foundation

struct LocalFirstDeckGeneratorService: DeckGenerating {
    private let localRepository: LocalJSONDeckRepository
    private let fallback: DeckGenerating

    init(localRepository: LocalJSONDeckRepository, fallback: DeckGenerating) {
        self.localRepository = localRepository
        self.fallback = fallback
    }

    func generateDeck(request: DeckGenerationRequest) async throws -> WordDeck {
        if let featuredShowID = FeaturedShow.resolveShowID(from: request.showName) {
            if let localDeck = localRepository.loadDeck(
                showName: request.showName,
                season: request.season,
                episode: request.episode
            ) {
                return localDeck.refreshedForInsertion()
            }

            let showDisplayName = FeaturedShow.supported
                .first(where: { $0.id == featuredShowID })?
                .displayName ?? request.showName
            throw DeckGeneratorError.localDeckNotFound(
                showName: showDisplayName,
                season: request.season,
                episode: request.episode
            )
        }

        if let localDeck = localRepository.loadDeck(
            showName: request.showName,
            season: request.season,
            episode: request.episode
        ) {
            return localDeck.refreshedForInsertion()
        }

        return try await fallback.generateDeck(request: request)
    }
}

private extension WordDeck {
    func refreshedForInsertion() -> WordDeck {
        let refreshedCards = cards.map { card in
            WordCard(
                word: card.word,
                phonetic: card.phonetic,
                pos: card.pos,
                meaning: card.meaning,
                phrase: card.phrase,
                previousSentence: card.previousSentence,
                exampleSentence: card.exampleSentence,
                exampleSentenceTranslation: card.exampleSentenceTranslation,
                nextSentence: card.nextSentence,
                sceneContext: card.sceneContext,
                usageTip: card.usageTip,
                alternatives: card.alternatives,
                difficulty: card.difficulty,
                volumeTier: card.volumeTier,
                status: .new,
                isStarred: card.isStarred,
                sourceShowName: card.sourceShowName,
                season: card.season,
                episode: card.episode
            )
        }

        return WordDeck(
            showName: showName,
            season: season,
            episode: episode,
            title: title,
            summary: summary,
            cards: refreshedCards,
            createdAt: Date()
        )
    }
}
