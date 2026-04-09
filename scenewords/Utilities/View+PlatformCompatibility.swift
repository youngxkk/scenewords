import SwiftUI

extension View {
    @ViewBuilder
    func swGroupedListStyle() -> some View {
#if os(macOS)
        self.listStyle(.automatic)
#else
        self.listStyle(.insetGrouped)
#endif
    }

    @ViewBuilder
    func swInlineTitleDisplayMode() -> some View {
#if os(macOS)
        self
#else
        self.navigationBarTitleDisplayMode(.inline)
#endif
    }
}
