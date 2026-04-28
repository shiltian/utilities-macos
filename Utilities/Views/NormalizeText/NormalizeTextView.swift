import SwiftUI

struct NormalizeTextView: View {
    @State private var state = NormalizeTextState()

    var body: some View {
        HStack(spacing: 0) {
            TextWrapPanel(
                title: "Input",
                placeholder: "Enter or paste text with smart quotes / dashes\u{2026}",
                text: $state.inputText,
                onPaste: { state.pasteToInput() },
                onCopy: nil,
                onClear: { state.clearInput() }
            )
            .frame(minWidth: 300)

            VStack {
                Button {
                    state.normalize()
                } label: {
                    Label("Normalize", systemImage: "arrow.right")
                        .frame(width: 100)
                }
                .buttonStyle(.bordered)
                .help("Replace smart quotes and dashes with ASCII equivalents")
            }
            .padding(.horizontal, 16)
            .background(.bar)

            TextWrapPanel(
                title: "Output",
                placeholder: "Result will appear here\u{2026}",
                text: $state.outputText,
                isEditable: false,
                onPaste: nil,
                onCopy: { state.copyOutput() },
                onClear: { state.clearOutput() }
            )
            .frame(minWidth: 300)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Normalize Text")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 400, height: 22, alignment: .center)
            }
        }
    }
}

#Preview {
    NormalizeTextView()
        .frame(width: 1000, height: 600)
}
