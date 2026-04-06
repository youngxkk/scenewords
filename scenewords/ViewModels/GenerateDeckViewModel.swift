import Foundation
import Combine

@MainActor
final class GenerateDeckViewModel: ObservableObject {
    @Published var showName: String = ""
    @Published var season: Int = 1
    @Published var episode: Int = 1
    @Published var errorMessage: String?
    @Published var isGenerating: Bool = false

    var canGenerate: Bool {
        validationError == nil && !isGenerating
    }

    var validationError: String? {
        if showName.swTrimmed.isEmpty {
            return "请输入剧名"
        }
        if season <= 0 || episode <= 0 {
            return "季和集必须大于 0"
        }
        return nil
    }

    func generate(using appViewModel: AppViewModel) async -> Bool {
        if let validationError {
            errorMessage = validationError
            return false
        }

        isGenerating = true
        defer { isGenerating = false }

        let request = DeckGenerationRequest(
            showName: showName.swTrimmed,
            season: season,
            episode: episode
        )

        do {
            try await appViewModel.generateDeck(request: request)
            return true
        } catch {
            if let localizedError = error as? LocalizedError,
               let description = localizedError.errorDescription {
                errorMessage = description
            } else {
                errorMessage = "生成失败，请稍后重试。"
            }
            return false
        }
    }
}
