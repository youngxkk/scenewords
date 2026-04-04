import Foundation
import Combine

@MainActor
final class GenerateDeckViewModel: ObservableObject {
    @Published var showName: String = ""
    @Published var season: Int = 1
    @Published var episode: Int = 1
    @Published var errorMessage: String?

    var canGenerate: Bool {
        validationError == nil
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

    func generate(using appViewModel: AppViewModel) -> Bool {
        if let validationError {
            errorMessage = validationError
            return false
        }

        let request = DeckGenerationRequest(
            showName: showName.swTrimmed,
            season: season,
            episode: episode
        )

        appViewModel.generateDeck(request: request)
        return true
    }
}
