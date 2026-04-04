import Foundation

enum MockDeckData {
    static var initialDecks: [WordDeck] {
        [friendsPilotDeck, friendsEpisode2Deck]
    }

    static var friendsPilotDeck: WordDeck {
        let showName = "Friends"
        let season = 1
        let episode = 1

        let cards: [WordCard] = [
            card(word: "aura", phonetic: "/ˈɔːrə/", pos: "noun", meaning: "气场；气息", phrase: "cleanse my aura", previous: "Phoebe: Ooh! Oh! (She starts to pluck at the air just in front of Ross.)", sentence: "Ross: No, no don't! Stop cleansing my aura! No, just leave my aura alone, okay?", sentenceTranslation: "罗斯：不，不要！别净化我的气场！别动我的气场，好吗？", scene: "Ross 低落时，Phoebe 试图“净化气场”的搞笑桥段。", alternatives: ["atmosphere", "vibe"], difficulty: .medium, isStarred: true, showName: showName, season: season, episode: episode),
            card(word: "lesbian", phonetic: "/ˈlezbiən/", pos: "noun", meaning: "女同性恋者", phrase: "she was a lesbian", previous: "Joey: And you never knew she was a lesbian...", sentence: "Ross: No!! Okay?! Why does everyone keep fixating on that?", sentenceTranslation: "罗斯：不是！！好吧？！为什么大家总盯着这件事不放？", scene: "Ross 谈到前妻 Carol 的性取向时的尴尬反应。", alternatives: ["gay woman"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "gravy boat", phonetic: "/ˈɡreɪvi boʊt/", pos: "noun", meaning: "酱汁船（餐具）", phrase: "a gravy boat", previous: "Rachel: I was in the room where we were keeping all the presents, and I was looking at this gravy boat.", sentence: "Rachel: This really gorgeous Lamauge gravy boat.", sentenceTranslation: "瑞秋：一个超漂亮的 Lamauge 酱汁船。", scene: "Rachel 解释逃婚原因时的经典台词。", alternatives: ["sauce boat"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "honeymoon", phonetic: "/ˈhʌnimuːn/", pos: "noun", meaning: "蜜月", phrase: "go on a honeymoon", previous: "Rachel: I was kinda supposed to be headed for Aruba on my honeymoon, so nothing!", sentence: "Ross: Right, you're not even getting your honeymoon, God..", sentenceTranslation: "罗斯：对，你连蜜月都没了，天啊……", scene: "Rachel 提到原本计划的蜜月旅行，Ross 接话安慰。", alternatives: ["bridal trip"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "metaphor", phonetic: "/ˈmetəfɔːr/", pos: "noun", meaning: "隐喻；比喻", phrase: "it's a metaphor", previous: "Chandler: What if I don't want to be a shoe? What if I wanna be a purse, y'know?", sentence: "Ross: No, I don't want you to buy me a hat. It's a metaphor, Daddy!", sentenceTranslation: "罗斯：不，我不是要你给我买帽子。这是个比喻，老爸！", scene: "Ross 在感情低谷时用“鞋子”做比喻，朋友吐槽。", alternatives: ["analogy", "symbol"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "divorce", phonetic: "/dɪˈvɔːrs/", pos: "noun", meaning: "离婚", phrase: "go through a divorce", previous: "Ross: Hi...", sentence: "Ross: I just want to be married again.", sentenceTranslation: "罗斯：我只是想再结一次婚。", scene: "Ross 刚离婚，情绪崩溃时的开场台词。", alternatives: ["separation"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "engagement", phonetic: "/ɪnˈɡeɪdʒmənt/", pos: "noun", meaning: "订婚", phrase: "engagement ring", previous: "Rachel: I was getting my nails done...", sentence: "Rachel: And I just started wondering, 'What if this is all wrong?'", sentenceTranslation: "瑞秋：我突然开始想，“如果这一切都错了怎么办？”", scene: "Rachel 回忆婚礼前内心动摇。", alternatives: ["betrothal"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "awkward", phonetic: "/ˈɔːkwərd/", pos: "adjective", meaning: "尴尬的", phrase: "awkward silence", previous: "Ross: I can't see this right now.", sentence: "Monica: Come sit down. Two seconds.", sentenceTranslation: "莫妮卡：来，坐下，就两秒。", scene: "朋友们想安慰 Ross，但气氛仍然尴尬。", alternatives: ["uncomfortable", "embarrassing"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "laundromat", phonetic: "/ˈlɔːndrəmæt/", pos: "noun", meaning: "自助洗衣店", phrase: "go to the laundromat", previous: "Monica: Welcome to the real world!", sentence: "Monica: It sucks. You're gonna love it.", sentenceTranslation: "莫妮卡：现实世界很糟，但你会爱上的。", scene: "Monica 鼓励 Rachel 独立生活。", alternatives: ["laundry"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "commitment", phonetic: "/kəˈmɪtmənt/", pos: "noun", meaning: "承诺；投入", phrase: "fear of commitment", previous: "Chandler: Sometimes I wish I was a lesbian...", sentence: "Ross: Did I say that out loud?", sentenceTranslation: "罗斯：我刚刚把那句话说出来了吗？", scene: "Ross 和朋友吐槽感情时提到承诺问题。", alternatives: ["dedication", "devotion"], difficulty: .hard, showName: showName, season: season, episode: episode),
            card(word: "career", phonetic: "/kəˈrɪr/", pos: "noun", meaning: "职业生涯；事业", phrase: "start a career", previous: "Rachel: I don't even have a pla-", sentence: "Monica: Well, you are not gonna be marrying him.", sentenceTranslation: "莫妮卡：反正你不会和他结婚了。", scene: "Rachel 开始思考独立和职业方向。", alternatives: ["profession", "occupation"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "figure out", phonetic: "/ˈfɪɡjər aʊt/", pos: "phrasal verb", meaning: "弄清楚；想明白", phrase: "figure out how", previous: "Rachel: I don't know where to start.", sentence: "Monica: You can stay with me. We will figure it out.", sentenceTranslation: "莫妮卡：你可以先住我这儿，我们会慢慢搞定。", scene: "Monica 给 Rachel 提供现实支持。", alternatives: ["work out", "find out"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "freak out", phonetic: "/friːk aʊt/", pos: "phrasal verb", meaning: "崩溃；慌张", phrase: "don't freak out", previous: "Rachel: Oh God.", sentence: "Rachel: Nobody told me life was gonna be this way.", sentenceTranslation: "瑞秋：天啊，没人告诉我人生会是这样。", scene: "Rachel 离开舒适区后的焦虑感。", alternatives: ["panic", "lose it"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "independent", phonetic: "/ˌɪndɪˈpendənt/", pos: "adjective", meaning: "独立的", phrase: "be independent", previous: "Rachel: No ring, no wedding, no Barry.", sentence: "Monica: You can do this on your own.", sentenceTranslation: "莫妮卡：你可以靠自己做到。", scene: "Rachel 迈向独立生活的心理转折。", alternatives: ["self-reliant", "autonomous"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "overreact", phonetic: "/ˌoʊvəriˈækt/", pos: "verb", meaning: "反应过度", phrase: "don't overreact", previous: "Joey: Calm down, man.", sentence: "Chandler: He always overreacts when he's emotional.", sentenceTranslation: "钱德勒：他一情绪化就会反应过度。", scene: "朋友调侃 Ross 的激烈反应。", alternatives: ["exaggerate"], difficulty: .hard, showName: showName, season: season, episode: episode)
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

    static var friendsEpisode2Deck: WordDeck {
        let showName = "Friends"
        let season = 1
        let episode = 2

        let cards: [WordCard] = [
            card(word: "detergent", phonetic: "/dɪˈtɜːrdʒənt/", pos: "noun", meaning: "洗涤剂", phrase: "laundry detergent", previous: "Monica: First, you need quarters.", sentence: "Rachel: I have no idea which detergent to buy.", sentenceTranslation: "瑞秋：我完全不知道该买哪种洗衣液。", scene: "Rachel 第一次自己去洗衣房。", alternatives: ["soap"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "quarter", phonetic: "/ˈkwɔːrtər/", pos: "noun", meaning: "25美分硬币", phrase: "insert quarters", previous: "Monica: Do you have change?", sentence: "Rachel: Why does every machine need a quarter?", sentenceTranslation: "瑞秋：为什么每台机器都要投硬币？", scene: "自助洗衣店常见高频词。", alternatives: ["coin"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "laundry", phonetic: "/ˈlɔːndri/", pos: "noun", meaning: "要洗的衣物", phrase: "do laundry", previous: "Rachel: This is all new to me.", sentence: "Monica: Everybody has to do laundry.", sentenceTranslation: "莫妮卡：每个人都得自己洗衣服。", scene: "独立生活日常场景。", alternatives: ["washing"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "refund", phonetic: "/ˈriːfʌnd/", pos: "noun", meaning: "退款", phrase: "ask for a refund", previous: "Rachel: This machine ate my money.", sentence: "Rachel: Can I get a refund for this?", sentenceTranslation: "瑞秋：这个能给我退钱吗？", scene: "Rachel 遇到机器故障时的表达。", alternatives: ["reimbursement"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "ownership", phonetic: "/ˈoʊnərʃɪp/", pos: "noun", meaning: "占有权；归属", phrase: "claim ownership", previous: "Woman: That's my basket.", sentence: "Rachel: No, those are my clothes.", sentenceTranslation: "瑞秋：不，那些衣服是我的。", scene: "洗衣房里围绕衣物归属发生冲突。", alternatives: ["possession"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "assertive", phonetic: "/əˈsɜːrtɪv/", pos: "adjective", meaning: "坚定表达的；果断的", phrase: "be assertive", previous: "Monica: You have to stand up for yourself.", sentence: "Rachel: I am trying to be assertive.", sentenceTranslation: "瑞秋：我正在努力更有主见。", scene: "Rachel 学习边界感与自我表达。", alternatives: ["confident", "firm"], difficulty: .hard, showName: showName, season: season, episode: episode),
            card(word: "intimidating", phonetic: "/ɪnˈtɪmɪdeɪtɪŋ/", pos: "adjective", meaning: "令人生畏的", phrase: "look intimidating", previous: "Rachel: She is staring at me.", sentence: "Monica: She only looks intimidating.", sentenceTranslation: "莫妮卡：她只是看起来很吓人。", scene: "Rachel 在冲突中紧张退缩。", alternatives: ["scary", "daunting"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "confront", phonetic: "/kənˈfrʌnt/", pos: "verb", meaning: "当面对质", phrase: "confront someone", previous: "Monica: Just go talk to her.", sentence: "Rachel: Fine, I'll confront her.", sentenceTranslation: "瑞秋：好吧，我去当面说。", scene: "Rachel 从逃避到正面沟通。", alternatives: ["face", "challenge"], difficulty: .hard, showName: showName, season: season, episode: episode),
            card(word: "confidence", phonetic: "/ˈkɑːnfɪdəns/", pos: "noun", meaning: "自信", phrase: "build confidence", previous: "Rachel takes a deep breath.", sentence: "Rachel: I think I'm getting some confidence back.", sentenceTranslation: "瑞秋：我觉得我的自信正在回来。", scene: "角色成长关键表达。", alternatives: ["self-belief"], difficulty: .medium, showName: showName, season: season, episode: episode),
            card(word: "responsibility", phonetic: "/rɪˌspɑːnsəˈbɪləti/", pos: "noun", meaning: "责任", phrase: "take responsibility", previous: "Monica: Welcome to adulthood.", sentence: "Rachel: Adult life has too much responsibility.", sentenceTranslation: "瑞秋：成年人的生活责任太多了。", scene: "从依赖到独立的主题词。", alternatives: ["duty", "obligation"], difficulty: .hard, showName: showName, season: season, episode: episode),
            card(word: "embarrassed", phonetic: "/ɪmˈbærəst/", pos: "adjective", meaning: "尴尬的；难为情的", phrase: "feel embarrassed", previous: "The machine suddenly stops.", sentence: "Rachel: This is so embarrassing.", sentenceTranslation: "瑞秋：这也太尴尬了。", scene: "洗衣房社交压力场景。", alternatives: ["awkward"], difficulty: .easy, showName: showName, season: season, episode: episode),
            card(word: "progress", phonetic: "/ˈprɑːɡres/", pos: "noun", meaning: "进步", phrase: "make progress", previous: "Monica smiles at Rachel.", sentence: "Monica: Look at you, that's progress.", sentenceTranslation: "莫妮卡：看看你，这就是进步。", scene: "剧集结尾的成长反馈。", alternatives: ["improvement"], difficulty: .easy, showName: showName, season: season, episode: episode)
        ]

        return WordDeck(
            showName: showName,
            season: season,
            episode: episode,
            title: "Friends · The One with the Sonogram at the End",
            summary: "围绕独立生活、边界感和现实挑战，强化日常场景高频词与情绪表达。",
            cards: cards,
            createdAt: Date().addingTimeInterval(-43_200)
        )
    }

    private static func card(
        word: String,
        phonetic: String,
        pos: String,
        meaning: String,
        phrase: String,
        previous: String,
        sentence: String,
        sentenceTranslation: String,
        scene: String,
        alternatives: [String],
        difficulty: WordDifficulty,
        isStarred: Bool = false,
        showName: String,
        season: Int,
        episode: Int
    ) -> WordCard {
        WordCard(
            word: word,
            phonetic: phonetic,
            pos: pos,
            meaning: meaning,
            phrase: phrase,
            previousSentence: previous,
            exampleSentence: sentence,
            exampleSentenceTranslation: sentenceTranslation,
            sceneContext: scene,
            alternatives: alternatives,
            difficulty: difficulty,
            isStarred: isStarred,
            sourceShowName: showName,
            season: season,
            episode: episode
        )
    }
}
