import SwiftUI

@main
struct SceneWordsApp: App {
    @StateObject private var appViewModel = AppViewModel.makeDefault()

    var body: some Scene {
        WindowGroup {
            SceneWordsRootView()
                .environmentObject(appViewModel)
        }
    }
}
