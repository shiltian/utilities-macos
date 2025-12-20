import SwiftUI

struct LLVMEncodingConverterView: View {
    @State private var state = LLVMEncodingConverterState()

    var body: some View {
        HStack(spacing: 0) {
            // Left panel - LLVM MC Encoding
            EncodingPanel(
                title: "LLVM MC Encoding",
                placeholder: "Enter LLVM MC encoding...\ne.g., 0xff,0xfe,0xff,0x65,0x0b,0xfe,0x00,0x00",
                text: $state.llvmMcText,
                onCopy: { state.copyLlvmMc() },
                onPaste: { state.pasteToLlvmMc() },
                onClear: { state.clearLlvmMc() }
            )
            .frame(minWidth: 300)

            // Center - Conversion buttons
            ConversionButtons(
                onConvertToRight: { state.convertToSp3() },
                onConvertToLeft: { state.convertToLlvmMc() }
            )

            // Right panel - SP3 Encoding
            EncodingPanel(
                title: "SP3 Encoding",
                placeholder: "Enter SP3 encoding...\ne.g., 0x65fffeff 0x0000fe0b",
                text: $state.sp3Text,
                onCopy: { state.copySp3() },
                onPaste: { state.pasteToSp3() },
                onClear: { state.clearSp3() }
            )
            .frame(minWidth: 300)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("LLVM MC and SP3 Converter")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 400, height: 22, alignment: .center)
            }
        }
    }
}

// MARK: - Encoding Panel

struct EncodingPanel: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let onCopy: () -> Void
    let onPaste: () -> Void
    let onClear: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        onPaste()
                    } label: {
                        Image(systemName: "doc.on.clipboard")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Paste from Clipboard")

                    Button {
                        onCopy()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .help("Copy to Clipboard")

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

            // Text editor
            MonospacedTextEditor(text: $text, placeholder: placeholder)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - Conversion Buttons

struct ConversionButtons: View {
    let onConvertToRight: () -> Void
    let onConvertToLeft: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button {
                onConvertToRight()
            } label: {
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
            .help("Convert LLVM MC → SP3")

            Button {
                onConvertToLeft()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
            .help("Convert SP3 → LLVM MC")
        }
        .padding(.horizontal, 16)
        .background(.bar)
    }
}

#Preview {
    LLVMEncodingConverterView()
        .frame(width: 1000, height: 600)
}

