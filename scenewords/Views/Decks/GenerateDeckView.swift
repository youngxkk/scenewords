import SwiftUI

struct GenerateDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GenerateDeckViewModel()

    var body: some View {
        Form {
            Section("剧集信息") {
                TextField("剧名（例如 Friends）", text: $viewModel.showName)
                    .textInputAutocapitalization(.words)

                Stepper(value: $viewModel.season, in: 1...50) {
                    HStack {
                        Text("季")
                        Spacer()
                        Text("\(viewModel.season)")
                            .foregroundStyle(.secondary)
                    }
                }

                Stepper(value: $viewModel.episode, in: 1...60) {
                    HStack {
                        Text("集")
                        Spacer()
                        Text("\(viewModel.episode)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button {
                    let success = viewModel.generate(using: appViewModel)
                    if success {
                        dismiss()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("生成")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(!viewModel.canGenerate)
            }
        }
        .navigationTitle("生成卡组")
        .navigationBarTitleDisplayMode(.inline)
        .alert("无法生成", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { newValue in
                if !newValue {
                    viewModel.errorMessage = nil
                }
            }
        )) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "未知错误")
        }
    }
}

#Preview {
    NavigationStack {
        GenerateDeckView()
            .environmentObject(AppViewModel.makeDefault())
    }
}
