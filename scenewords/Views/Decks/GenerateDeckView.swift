import SwiftUI

struct GenerateDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GenerateDeckViewModel()
    @State private var didApplyPrefill = false

    private let prefillShowName: String?
    private let prefillSeason: Int
    private let prefillEpisode: Int

    init(
        prefillShowName: String? = nil,
        prefillSeason: Int = 1,
        prefillEpisode: Int = 1
    ) {
        self.prefillShowName = prefillShowName
        self.prefillSeason = prefillSeason
        self.prefillEpisode = prefillEpisode
    }

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
                    Task {
                        let success = await viewModel.generate(using: appViewModel)
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isGenerating {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("生成")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(!viewModel.canGenerate)
            } footer: {
                Text("当前数据源：\(appViewModel.generationSourceLabel)")
            }
        }
        .navigationTitle("生成卡组")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !didApplyPrefill else { return }
            didApplyPrefill = true

            if let prefillShowName, !prefillShowName.swTrimmed.isEmpty {
                viewModel.showName = prefillShowName
            }
            viewModel.season = max(1, prefillSeason)
            viewModel.episode = max(1, prefillEpisode)
        }
        .overlay {
            if viewModel.isGenerating {
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.regular)
                        Text("正在生成词卡，请稍候...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
                .transition(.opacity)
            }
        }
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
