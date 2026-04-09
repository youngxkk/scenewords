import SwiftUI
#if canImport(UIKit)
import UIKit
private typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
private typealias PlatformImage = NSImage
#endif

struct DeckListView: View {
    @State private var showGeneratePage = false
    @State private var selectedShow: FeaturedShow?

    var body: some View {
        List {
            Section {
                FeaturedShowGrid { show in
                    selectedShow = show
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                .listRowBackground(Color.clear)
            } header: {
                Text("热门影视")
            }
        }
        .swGroupedListStyle()
        .navigationTitle("SceneWords")
        .toolbar {
#if os(macOS)
            ToolbarItem {
                Button {
                    showGeneratePage = true
                } label: {
                    Label("对话/生成", systemImage: "plus.bubble")
                }
            }
#else
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showGeneratePage = true
                } label: {
                    Label("对话/生成", systemImage: "plus.bubble")
                }
            }
#endif
        }
        .navigationDestination(isPresented: $showGeneratePage) {
            GenerateDeckView()
        }
        .navigationDestination(item: $selectedShow) { show in
            FeaturedShowDeckListView(show: show)
        }
    }
}

private struct FeaturedShowGrid: View {
    let onTap: (FeaturedShow) -> Void
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(FeaturedShow.supported) { show in
                Button {
                    onTap(show)
                } label: {
                    ShowPosterTile(show: show)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ShowPosterTile: View {
    let show: FeaturedShow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ShowCoverImage(show: show)

            Text(show.localizedName)
                .font(.headline)
                .lineLimit(1)

            Text(show.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}

private struct ShowCoverImage: View {
    let show: FeaturedShow

    var body: some View {
        Group {
            if let image = resolvedImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
            } else {
                LinearGradient(
                    colors: [.blue.opacity(0.55), .teal.opacity(0.55), .black.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay(alignment: .center) {
                    Image(systemName: "tv.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
        }
        .aspectRatio(2.0 / 3.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var resolvedImage: Image? {
        let extensions = ["jpg", "jpeg", "png", "webp", "heic"]
        let names = [show.coverImageBaseName, show.id]
        let subdirectories = ["Resources/Covers", "Covers", "Resources/Shows/Covers", "Shows/Covers", "Resources/Shows", "Shows"]

        if let image = loadImage(named: show.coverImageBaseName) {
            return makeImage(from: image)
        }

        for name in names {
            for ext in extensions {
                for subdirectory in subdirectories {
                    if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: subdirectory),
                       let image = loadImage(at: url.path) {
                        return makeImage(from: image)
                    }
                }

                if let url = Bundle.main.url(forResource: name, withExtension: ext),
                   let image = loadImage(at: url.path) {
                    return makeImage(from: image)
                }
            }
        }

        return nil
    }

    private func makeImage(from image: PlatformImage) -> Image {
#if canImport(UIKit)
        Image(uiImage: image)
#elseif canImport(AppKit)
        Image(nsImage: image)
#endif
    }

    private func loadImage(named name: String) -> PlatformImage? {
#if canImport(UIKit)
        PlatformImage(named: name)
#elseif canImport(AppKit)
        Bundle.main.image(forResource: name)
#endif
    }

    private func loadImage(at path: String) -> PlatformImage? {
#if canImport(UIKit)
        PlatformImage(contentsOfFile: path)
#elseif canImport(AppKit)
        PlatformImage(contentsOfFile: path)
#endif
    }
}

struct DeckListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DeckListView()
                .environmentObject(AppViewModel.makeDefault())
        }
    }
}
