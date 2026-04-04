import Foundation

enum MockDeckData {
    static var initialDecks: [WordDeck] {
        [friendsPilotDeck]
    }

    static var friendsPilotDeck: WordDeck {
        let showName = "Friends"
        let season = 1
        let episode = 1

        let cards: [WordCard] = [
            WordCard(
                word: "aisle",
                meaning: "走道；过道",
                exampleSentence: "Rachel runs out of the wedding and ends up in the coffeehouse still in her dress.",
                sceneContext: "Central Perk 初登场场景，Rachel 刚逃婚，情绪很混乱。",
                difficulty: .medium,
                sourceShowName: showName,
                season: season,
                episode: episode
            ),
            WordCard(
                word: "engaged",
                meaning: "已订婚的",
                exampleSentence: "Barry and Rachel were engaged before she suddenly changed her mind.",
                sceneContext: "Monica 在安慰 Rachel 时提到她的婚约状态。",
                difficulty: .easy,
                sourceShowName: showName,
                season: season,
                episode: episode
            ),
            WordCard(
                word: "awkward",
                meaning: "尴尬的",
                exampleSentence: "Ross feels awkward when he talks about his recent divorce.",
                sceneContext: "Ross 向朋友吐露婚姻问题，语气局促。",
                difficulty: .easy,
                sourceShowName: showName,
                season: season,
                episode: episode
            ),
            WordCard(
                word: "commitment",
                meaning: "承诺；投入",
                exampleSentence: "The group jokes about fear of commitment in relationships.",
                sceneContext: "朋友们讨论感情观，出现关于长期关系的表达。",
                difficulty: .hard,
                sourceShowName: showName,
                season: season,
                episode: episode
            ),
            WordCard(
                word: "career",
                meaning: "职业生涯；事业",
                exampleSentence: "Rachel realizes she needs to build a career on her own.",
                sceneContext: "Rachel 决定离开父母安排的人生，开始独立。",
                difficulty: .medium,
                sourceShowName: showName,
                season: season,
                episode: episode
            ),
            WordCard(
                word: "figure out",
                meaning: "弄清楚；想明白",
                exampleSentence: "Monica tells Rachel she will figure out life step by step.",
                sceneContext: "好友鼓励场景，常用口语短语。",
                difficulty: .easy,
                sourceShowName: showName,
                season: season,
                episode: episode
            )
        ]

        return WordDeck(
            showName: showName,
            season: season,
            episode: episode,
            title: "Friends · The One Where Monica Gets a Roommate",
            summary: "围绕 Rachel 逃婚后的首次亮相，聚焦人际关系、情感表达与生活选择相关词汇。",
            cards: cards,
            createdAt: Date().addingTimeInterval(-86_400)
        )
    }
}
