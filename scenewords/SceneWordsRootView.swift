import SwiftUI

struct SceneWordsRootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DeckListView()
            }
            .tabItem {
                Label("卡组", systemImage: "square.stack.3d.up")
            }

            NavigationStack {
                ReviewListView()
            }
            .tabItem {
                Label("复习", systemImage: "book")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("我", systemImage: "person.crop.circle")
            }
        }
    }
}

struct SceneWordsRootView_Previews: PreviewProvider {
    static var previews: some View {
        SceneWordsRootView()
            .environmentObject(AppViewModel.makeDefault())
    }
}
