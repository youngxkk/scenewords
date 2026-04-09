import SwiftUI

// Compatibility wrapper to avoid Xcode trying to open a missing legacy file.
struct ContentView: View {
    var body: some View {
        SceneWordsRootView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppViewModel.makeDefault())
    }
}
