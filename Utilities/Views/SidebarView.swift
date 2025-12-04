import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState

        List(selection: $state.selectedTool) {
            ForEach(appState.filteredTools) { tool in
                NavigationLink(value: tool) {
                    Label(tool.displayName, systemImage: tool.icon)
                }
                .tag(tool)
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $state.searchText, placement: .sidebar, prompt: "Search...")
        .navigationTitle("Tools")
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                Divider()
                Button {
                    sendFeedback()
                } label: {
                    Label("Send Feedback", systemImage: "envelope")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderless)
                .controlSize(.small)

                Text("Utilities 1.0")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private func sendFeedback() {
        if let url = URL(string: "mailto:feedback@example.com?subject=UtilitiesMac%20Feedback") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    SidebarView()
        .environment(AppState())
        .frame(width: 220)
}

