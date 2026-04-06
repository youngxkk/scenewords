import Foundation

struct LearningProgress: Codable {
    var status: WordStatus
    var isStarred: Bool
    var dueAt: Date
    var lastReviewedAt: Date?
    var intervalDays: Int
}

final class LearningProgressStore {
    private var records: [String: LearningProgress]
    private let fileURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(fileManager: FileManager = .default) {
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let appDirectory = supportDirectory.appendingPathComponent("SceneWords", isDirectory: true)

        if !fileManager.fileExists(atPath: appDirectory.path) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }

        self.fileURL = appDirectory.appendingPathComponent("learning_progress.json", isDirectory: false)
        self.records = Self.loadRecords(from: fileURL, decoder: decoder)
    }

    func progress(for key: String) -> LearningProgress? {
        records[key]
    }

    func upsert(_ progress: LearningProgress, for key: String) {
        records[key] = progress
        save()
    }

    private func save() {
        do {
            let data = try encoder.encode(records)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save learning progress: \(error)")
        }
    }

    private static func loadRecords(from url: URL, decoder: JSONDecoder) -> [String: LearningProgress] {
        guard let data = try? Data(contentsOf: url) else {
            return [:]
        }

        return (try? decoder.decode([String: LearningProgress].self, from: data)) ?? [:]
    }
}
