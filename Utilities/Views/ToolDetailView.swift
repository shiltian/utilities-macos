import SwiftUI

struct ToolDetailView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            switch appState.selectedTool {
            case .markdownPreview:
                MarkdownPreviewView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ToolDetailView()
        .environment(AppState())
}

