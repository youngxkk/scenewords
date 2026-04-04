import Foundation

struct MockDeckGeneratorService: DeckGenerating {
    func generateDeck(request: DeckGenerationRequest) -> WordDeck {
        if request.showName.swTrimmed.caseInsensitiveCompare("Friends") == .orderedSame,
           request.season == 1,
           request.episode == 1 {
            return MockDeckData.friendsPilotDeck.withFreshIDsAndDate()
        }

        let normalizedName = request.showName.swTrimmed
        let showName = normalizedName.isEmpty ? "Unknown Show" : normalizedName
        let season = max(1, request.season)
        let episode = max(1, request.episode)

        let baseCards: [(String, String, String, String, WordDifficulty)] = [
            ("plot twist", "剧情反转", "The scene ends with a small plot twist that changes the mood.", "角色关系突然变化，推动后续故事。", .medium),
            ("argue", "争论；争吵", "Two friends argue about whether to tell the truth.", "朋友在客厅激烈讨论，语速较快。", .easy),
            ("confident", "自信的", "She sounds confident when introducing herself in the new city.", "新角色初次登场，自我表达清晰。", .easy),
            ("deal with", "处理；应对", "He needs to deal with an unexpected problem at work.", "职场对话场景，常见动词短语。", .medium),
            ("honest", "诚实的", "Being honest is the key point in this conversation.", "情感沟通场景，语气认真。", .easy)
        ]

        let cards = baseCards.map { entry in
            WordCard(
                word: entry.0,
                meaning: entry.1,
                exampleSentence: entry.2,
                sceneContext: entry.3,
                difficulty: entry.4,
                sourceShowName: showName,
                season: season,
                episode: episode
            )
        }

        return WordDeck(
            showName: showName,
            season: season,
            episode: episode,
            title: "\(showName) · SceneWords Pack",
            summary: "根据 \(showName) \(formattedEpisode(season: season, episode: episode)) 生成的示例词卡，覆盖剧情理解与口语表达。",
            cards: cards,
            createdAt: Date()
        )
    }

    private func formattedEpisode(season: Int, episode: Int) -> String {
        "S\(String(format: "%02d", season))E\(String(format: "%02d", episode))"
    }
}

private extension WordDeck {
    func withFreshIDsAndDate() -> WordDeck {
        let refreshedCards = cards.map { card in
            WordCard(
                word: card.word,
                meaning: card.meaning,
                exampleSentence: card.exampleSentence,
                sceneContext: card.sceneContext,
                difficulty: card.difficulty,
                status: .new,
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
