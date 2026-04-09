import SwiftUI
import AVFoundation

struct WordCardPagerView: View {
    let cards: [WordCard]
    @Binding var selectedCardID: UUID?
    let onStatusChange: (UUID, WordStatus) -> Void
    let onStarChange: (UUID, Bool) -> Void

    init(
        cards: [WordCard],
        selectedCardID: Binding<UUID?>,
        onStatusChange: @escaping (UUID, WordStatus) -> Void,
        onStarChange: @escaping (UUID, Bool) -> Void = { _, _ in }
    ) {
        self.cards = cards
        self._selectedCardID = selectedCardID
        self.onStatusChange = onStatusChange
        self.onStarChange = onStarChange
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(cards) { card in
                        WordStudyCardView(
                            card: card,
                            onStatusChange: { status in
                                onStatusChange(card.id, status)
                            },
                            onStarChange: { isStarred in
                                onStarChange(card.id, isStarred)
                            }
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .id(card.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: selectionBinding)
        }
        .onAppear {
            if selectedCardID == nil {
                selectedCardID = cards.first?.id
            }
        }
        .onChange(of: cards.map(\.id)) { _, newIDs in
            guard !newIDs.isEmpty else {
                selectedCardID = nil
                return
            }

            if let selectedCardID, newIDs.contains(selectedCardID) {
                return
            }

            selectedCardID = newIDs.first
        }
    }

    private var selectionBinding: Binding<UUID?> {
        Binding(
            get: {
                selectedCardID ?? cards.first?.id
            },
            set: { newValue in
                selectedCardID = newValue
            }
        )
    }
}

extension Font {
    static var superTitle: Font {
        // 这里的 size 随你定，42 或是 60 都行
        return .system(size: 42, weight: .bold, design: .rounded)
    }
}

enum InfoTab: String, Identifiable, CaseIterable {
    case scene = "场景说明"
    case tip = "使用提示"
    case alternatives = "近义表达"
    var id: String { rawValue }
}

struct WordStudyCardView: View {
    let card: WordCard
    let onStatusChange: (WordStatus) -> Void
    let onStarChange: (Bool) -> Void

    @State private var selectedTab: InfoTab = .scene

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(card.word)
                        .font(.superTitle.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)

                    HStack(spacing: 12) {
                        Button {
                            WordPronouncer.shared.speak(card.word)
                        } label: {
                            HStack(spacing: 6) {
                                Text("美")
                                    .font(.system(size: 11, weight: .bold))
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.secondary.opacity(0.15), in: Capsule())
                        }
                        .buttonStyle(.plain)

                        Text(formattedPhonetic)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        if let pos = card.pos, !pos.isEmpty {
                            Text(pos)
                                .font(.body.weight(.light))
                                .foregroundStyle(.primary)
                        }

                        Text(card.meaning)
                            .font(.body)
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                    }
                    .padding(.top, 2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Button {
                        onStarChange(!card.isStarred)
                    } label: {
                        Image(systemName: card.isStarred ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(card.isStarred ? .yellow : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 30) {
                SceneTripletSection(
                    previous: card.previousSentence,
                    current: card.exampleSentence,
                    currentTranslation: card.exampleSentenceTranslation,
                    next: card.nextSentence
                )
                
                Group {
                    if selectedTab == .scene {
                        CardSection(title: "场景说明", value: card.sceneContext)
                    } else if selectedTab == .tip {
                        CardSection(title: "使用提示", value: card.usageTip ?? "暂无使用提示")
                    } else if selectedTab == .alternatives {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("近义表达")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            if card.alternatives.isEmpty {
                                Text("暂无近义表达")
                                    .font(.body)
                                    .foregroundStyle(.tertiary)
                            } else {
                                ViewThatFits(in: .horizontal) {
                                    HStack(spacing: 8) {
                                        ForEach(card.alternatives, id: \.self) { item in
                                            Text(item)
                                                .font(.body)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Color.secondary.opacity(0.1), in: Capsule())
                                        }
                                    }
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(card.alternatives, id: \.self) { item in
                                            Text(item)
                                                .font(.body)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(Color.secondary.opacity(0.1), in: Capsule())
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }

            Spacer(minLength: 0)

            HStack {
                HStack(spacing: 4) {
                    ForEach(InfoTab.allCases) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            Text(tab.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    ZStack {
                                        if selectedTab == tab {
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .fill(Color.secondary.opacity(0.12))
                                        }
                                    }
                                )
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
                Menu {
                    Picker("掌握状态", selection: Binding(
                        get: { card.status },
                        set: { newStatus in
                            onStatusChange(newStatus)
                        }
                    )) {
                        ForEach(WordStatus.allCases) { status in
                            Text(status.displayName.capitalized).tag(status)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(card.status.displayName.capitalized)
                            .font(.footnote.weight(.medium))
                            .fixedSize(horizontal: true, vertical: false)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 9))
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 100, style: .continuous))
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                }
                .tint(.primary)
            }
            .padding(.horizontal, -4)
            .padding(.bottom, -4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 8)
        )
    }

    private var formattedPhonetic: String {
        let raw = (card.phonetic ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return "/-/" }
        if raw.hasPrefix("/") && raw.hasSuffix("/") {
            return raw
        }
        return "/\(raw)/"
    }
}

private final class WordPronouncer {
    static let shared = WordPronouncer()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }
}

private struct SceneTripletSection: View {
    let previous: String?
    let current: String
    let currentTranslation: String?
    let next: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("原文")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let previous, !previous.isEmpty {
                Text(previous)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Text(current)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            if let currentTranslation, !currentTranslation.isEmpty {
                Text(currentTranslation)
                    .font(.system(size: 14))
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

//            if let next, !next.isEmpty {
//                Text(next)
//                    .font(.body)
//                    .foregroundStyle(.primary)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
        }
    }
}

private struct CardSection: View {
    let title: String
    let value: String
    var emphasis: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(emphasis ? .title3.weight(.semibold) : .body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct WordCardPagerPreviewHost: View {
    @State private var selectedCardID: UUID?
    @State private var cards: [WordCard] = [
        WordCard(
            word: "comprise",
            phonetic: "/kəmˈpraɪz/",
            pos: "vt.",
            meaning: "包括，由…组成",
            previousSentence: "The committee discussed the final report in detail.",
            exampleSentence: "Twelve departments comprise the whole research center.",
            exampleSentenceTranslation: "整个研究中心由12个部门组成。",
            sceneContext: "正式表达中常见，用于说明整体和组成部分关系。",
            alternatives: ["consist of", "be made up of"],
            difficulty: .medium,
            sourceShowName: "Demo Show",
            season: 1,
            episode: 1
        )
    ]

    var body: some View {
        WordCardPagerView(
            cards: cards,
            selectedCardID: $selectedCardID,
            onStatusChange: { id, status in
                if let index = cards.firstIndex(where: { $0.id == id }) {
                    cards[index].status = status
                }
            },
            onStarChange: { id, isStarred in
                if let index = cards.firstIndex(where: { $0.id == id }) {
                    cards[index].isStarred = isStarred
                }
            }
        )
    }
}

struct WordCardPagerView_Previews: PreviewProvider {
    static var previews: some View {
        WordCardPagerPreviewHost()
    }
}
