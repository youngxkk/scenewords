import Foundation

struct FeaturedShow: Identifiable, Hashable {
    let id: String
    let displayName: String
    let localizedName: String
    let seasonCount: Int
    let coverImageBaseName: String
    let aliases: [String]

    var generationShowName: String {
        displayName
    }

    static let supported: [FeaturedShow] = [
        FeaturedShow(
            id: "friends",
            displayName: "Friends",
            localizedName: "老友记",
            seasonCount: 10,
            coverImageBaseName: "friends",
            aliases: ["friends", "老友记"]
        ),
        FeaturedShow(
            id: "silicon_valley",
            displayName: "Silicon Valley",
            localizedName: "硅谷",
            seasonCount: 6,
            coverImageBaseName: "silicon_valley",
            aliases: ["silicon valley", "silicon_valley", "硅谷"]
        ),
        FeaturedShow(
            id: "modern_family",
            displayName: "Modern Family",
            localizedName: "摩登家庭",
            seasonCount: 11,
            coverImageBaseName: "modern_family",
            aliases: ["modern family", "modern_family", "摩登家庭"]
        ),
        FeaturedShow(
            id: "breaking_bad",
            displayName: "Breaking Bad",
            localizedName: "绝命毒师",
            seasonCount: 5,
            coverImageBaseName: "breaking_bad",
            aliases: ["breaking bad", "breaking_bad", "绝命毒师"]
        )
    ]

    static func resolveShowID(from rawName: String) -> String? {
        let normalizedInput = normalize(rawName)
        guard !normalizedInput.isEmpty else { return nil }

        for show in supported {
            if normalize(show.id) == normalizedInput {
                return show.id
            }

            if show.aliases.contains(where: { normalize($0) == normalizedInput }) {
                return show.id
            }

            if normalize(show.displayName) == normalizedInput || normalize(show.localizedName) == normalizedInput {
                return show.id
            }
        }

        return nil
    }

    func matches(showName: String) -> Bool {
        guard let resolved = Self.resolveShowID(from: showName) else { return false }
        return resolved == id
    }

    private static func normalize(_ raw: String) -> String {
        raw
            .swTrimmed
            .lowercased()
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "  ", with: " ")
    }
}
