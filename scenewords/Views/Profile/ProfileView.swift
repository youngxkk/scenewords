import SwiftUI

struct ProfileView: View {
    private let menuItems: [String] = [
        "设置",
        "通知提醒",
        "关于",
        "隐私政策",
        "用户协议"
    ]

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Max")
                            .font(.title3.weight(.semibold))
                        Text("母语：简体中文")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("学习语言：英语")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("功能") {
                ForEach(menuItems, id: \.self) { item in
                    NavigationLink(item) {
                        StaticPageView(title: item)
                    }
                }
            }
        }
        .swGroupedListStyle()
        .navigationTitle("我")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
    }
}
