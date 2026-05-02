import SwiftUI

struct TextWrapUnwrapView: View {
    @Bindable var state: TextWrapUnwrapState

    var body: some View {
        HStack(spacing: 0) {
            // Left panel — Input
            TextWrapPanel(
                title: "Input",
                placeholder: "Enter or paste text to wrap / unwrap…",
                text: $state.inputText,
                onPaste: { state.pasteToInput() },
                onCopy: nil,
                onClear: { state.clearInput() }
            )
            .frame(minWidth: 300)

            // Center — Controls
            VStack(spacing: 16) {
                lineWidthControl

                Button {
                    state.wrap()
                } label: {
                    Label("Wrap", systemImage: "arrow.right")
                        .frame(width: 80)
                }
                .buttonStyle(.bordered)
                .help("Wrap text at \(state.lineWidth) characters")

                Button {
                    state.unwrap()
                } label: {
                    Label("Unwrap", systemImage: "arrow.right")
                        .frame(width: 80)
                }
                .buttonStyle(.bordered)
                .help("Unwrap text (join paragraph lines)")
            }
            .padding(.horizontal, 16)
            .background(.bar)

            // Right panel — Output (read-only, selectable)
            TextWrapPanel(
                title: "Output",
                placeholder: "Result will appear here…",
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
                Text("Text Wrap / Unwrap")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 400, height: 22, alignment: .center)
            }
        }
    }

    private var lineWidthControl: some View {
        VStack(spacing: 4) {
            Text("Line Width")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                TextField("", value: $state.lineWidth, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 52)
                    .multilineTextAlignment(.center)

                Stepper("", value: $state.lineWidth, in: 1...999)
                    .labelsHidden()
            }
        }
    }
}

// MARK: - Text Wrap Panel

struct TextWrapPanel: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isEditable: Bool = true
    var onPaste: (() -> Void)?
    var onCopy: (() -> Void)?
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 8) {
                    if let onPaste {
                        Button {
                            onPaste()
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .help("Paste from Clipboard")
                    }

                    if let onCopy {
                        Button {
                            onCopy()
                        } label: {
                            Image(systemName: "doc.on.doc")
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .help("Copy to Clipboard")
                    }

                    Button {
                        onClear()
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Clear")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.bar)

            Divider()

            MonospacedTextEditor(text: $text, placeholder: placeholder, isEditable: isEditable)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

#Preview {
    TextWrapUnwrapView(state: TextWrapUnwrapState())
        .frame(width: 1000, height: 600)
}
