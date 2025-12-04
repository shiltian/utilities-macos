import SwiftUI
import WebKit

struct MarkdownOutputView: View {
    @Bindable var state: MarkdownPreviewState

    var body: some View {
        VStack(spacing: 0) {
            // Header with mode picker and action button
            HStack {
                Text("Output:")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 8) {
                    // Action button changes based on mode
                    if state.outputMode == .preview {
                        Button("Open in Browser") {
                            state.openInBrowser()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    } else {
                        Button("Copy") {
                            state.copyOutput()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }

                    // Mode picker
                    Picker("", selection: $state.outputMode) {
                        ForEach(MarkdownOutputMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 120)
                    .controlSize(.small)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.bar)

            Divider()

            // Content based on mode
            Group {
                switch state.outputMode {
                case .preview:
                    WebView(html: state.previewHTML)
                case .html:
                    CodeView(code: state.htmlOutput)
                case .htmlCSS:
                    CodeView(code: state.htmlWithCSSOutput)
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - WebView for Preview

struct WebView: NSViewRepresentable {
    let html: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}

// MARK: - Code View for HTML output

struct CodeView: View {
    let code: String

    var body: some View {
        ScrollView {
            Text(code)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}

#Preview("Preview Mode") {
    let state = MarkdownPreviewState()
    state.loadSample()
    return MarkdownOutputView(state: state)
        .frame(width: 500, height: 600)
}

#Preview("HTML Mode") {
    let state = MarkdownPreviewState()
    state.loadSample()
    state.outputMode = .html
    return MarkdownOutputView(state: state)
        .frame(width: 500, height: 600)
}

