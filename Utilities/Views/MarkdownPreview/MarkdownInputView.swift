import SwiftUI

struct MarkdownInputView: View {
    @Bindable var state: MarkdownPreviewState

    var body: some View {
        VStack(spacing: 0) {
            // Header with buttons
            HStack {
                Text("Input:")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 8) {
                    Button("Clipboard") {
                        state.pasteFromClipboard()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button("Sample") {
                        state.loadSample()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button("Clear") {
                        state.clear()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.bar)

            Divider()

            // Text editor
            TextEditor(text: $state.inputText)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
                .onChange(of: state.inputText) {
                    state.scheduleSave()
                }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

#Preview {
    MarkdownInputView(state: MarkdownPreviewState())
        .frame(width: 400, height: 500)
}

