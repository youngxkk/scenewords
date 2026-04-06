import Foundation

struct MockDeckGeneratorService: DeckGenerating {
    func generateDeck(request: DeckGenerationRequest) async throws -> WordDeck {
        if request.showName.swTrimmed.caseInsensitiveCompare("Friends") == .orderedSame,
           request.season == 1,
           request.episode == 1 {
            return MockDeckData.friendsPilotDeck.withFreshIDsAndDate()
        }

        let normalizedName = request.showName.swTrimmed
        let showName = normalizedName.isEmpty ? "Unknown Show" : normalizedName
        let season = max(1, request.season)
        let episode = max(1, request.episode)

        let baseCards: [(String, String, String, String, String, String, String, String, String, String, [String], WordDifficulty)] = [
            ("plot twist", "/plɑːt twɪst/", "noun", "剧情反转", "a plot twist", "Everyone thinks the conflict is over.", "The scene ends with a small plot twist that changes the mood.", "The characters immediately rethink their choices.", "角色关系突然变化，推动后续故事。", "常用于影视讨论语境。", ["turn", "surprise ending"], .medium),
            ("argue", "/ˈɑːrɡjuː/", "verb", "争论；争吵", "argue about", "They start with a calm discussion.", "Two friends argue about whether to tell the truth.", "One of them walks away to cool down.", "朋友在客厅激烈讨论，语速较快。", "argue with 人；argue about 事。", ["quarrel", "dispute"], .easy),
            ("confident", "/ˈkɑːnfɪdənt/", "adjective", "自信的", "feel confident", "She takes a deep breath before speaking.", "She sounds confident when introducing herself in the new city.", "Others respond positively to her tone.", "新角色初次登场，自我表达清晰。", "常见搭配：be confident about/in。", ["self-assured"], .easy),
            ("deal with", "/diːl wɪð/", "phrasal verb", "处理；应对", "deal with problems", "A sudden issue interrupts the plan.", "He needs to deal with an unexpected problem at work.", "His teammate offers help right away.", "职场对话场景，常见动词短语。", "口语和职场语境都很常见。", ["handle", "cope with"], .medium),
            ("honest", "/ˈɑːnɪst/", "adjective", "诚实的", "be honest with", "They hesitate before sharing their feelings.", "Being honest is the key point in this conversation.", "The misunderstanding clears up after that.", "情感沟通场景，语气认真。", "be honest with sb. 表示对某人坦诚。", ["truthful", "frank"], .easy)
        ]

        let cards = baseCards.map { entry in
            WordCard(
                word: entry.0,
                phonetic: entry.1,
                pos: entry.2,
                meaning: entry.3,
                phrase: entry.4,
                previousSentence: entry.5,
                exampleSentence: entry.6,
                nextSentence: entry.7,
                sceneContext: entry.8,
                usageTip: entry.9,
                alternatives: entry.10,
                difficulty: entry.11,
                volumeTier: WordVolumeTier.from(difficulty: entry.11),
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
