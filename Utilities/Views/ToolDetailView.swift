import SwiftUI

struct ToolDetailView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            switch appState.selectedTool {
            case .markdownPreview:
                MarkdownPreviewView(state: appState.markdownPreviewState)
            case .textWrapUnwrap:
                TextWrapUnwrapView(state: appState.textWrapUnwrapState)
            case .normalizeText:
                NormalizeTextView(state: appState.normalizeTextState)
            case .llvmMcSp3Converter:
                LLVMEncodingConverterView(state: appState.llvmEncodingConverterState)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ToolDetailView()
        .environment(AppState())
}

