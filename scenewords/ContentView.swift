import SwiftUI

// Compatibility wrapper to avoid Xcode trying to open a missing legacy file.
struct ContentView: View {
    var body: some View {
        SceneWordsRootView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppViewModel.makeDefault())
}
