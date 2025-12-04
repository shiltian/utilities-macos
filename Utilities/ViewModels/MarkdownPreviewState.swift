import SwiftUI
import Observation

/// Output mode for the markdown preview
enum MarkdownOutputMode: String, CaseIterable {
    case preview = "Preview"
    case html = "HTML"
    case htmlCSS = "HTML + CSS"
}

/// State for the Markdown Preview tool
@Observable
final class MarkdownPreviewState {
    // MARK: - Cache Configuration
    private static let cacheKey = "MarkdownPreviewInputCache"
    private static let saveDebounceSeconds: UInt64 = 1

    // MARK: - Properties
    var inputText: String = ""
    var outputMode: MarkdownOutputMode = .preview

    /// Task for debounced auto-save
    private var saveTask: Task<Void, Never>?

    // MARK: - Initialization

    init() {
        // Restore cached input from previous session
        if let cachedText = UserDefaults.standard.string(forKey: Self.cacheKey) {
            inputText = cachedText
        }
    }

    /// Sample markdown text for demonstration
    static let sampleMarkdown = """
    # Heading 1

    Paragraphs are separated by a blank line.

    2nd paragraph. *Italic*, **bold**, `monospace`. Itemized lists look like:

    * this one
    * that one
    * the other one

    Note that --- not considering the asterisk --- the actual text content starts at 3-columns in.

    > Block quotes are
    > written like so.
    >
    > They can span multiple paragraphs,
    > if you like.

    With `smartyPants` set to true in the markdown module configuration, you can format your content smartly:

    - Use 3 dashes `---` for an em-dash. (e.g. Note --- Its a cool day)
    - Use 2 dashes `--` for an en-dash or ranges (e.g. "It's all in chapters 12--14").
    - Three dots `...` will be converted to an ellipsis. (e.g. He goes on and on ...)
    - Straight quotes ( `"` and `'` ) will be converted to "curly double" and 'curly single'
    - Backticks-style quotes (`like this`) will be shown as curly entities as well

    ## Heading 2

    Here is a numbered list:

    1. first item
    2. second item
    3. third item

    ### Heading 3

    Here's a code sample:

    ```swift
    func greet(name: String) -> String {
        return "Hello, \\(name)!"
    }
    ```

    And inline code: `let x = 42`

    #### Links and Images

    [Link to Apple](https://apple.com)

    ---

    That's all folks!
    """

    /// Generate HTML from markdown
    var htmlOutput: String {
        MarkdownConverter.toHTML(inputText)
    }

    /// Generate HTML with embedded CSS
    var htmlWithCSSOutput: String {
        MarkdownConverter.toHTMLWithCSS(inputText)
    }

    /// Full HTML document for preview (with styling)
    var previewHTML: String {
        MarkdownConverter.toPreviewHTML(inputText)
    }

    // MARK: - Auto-Save

    /// Schedule a debounced save of the input text to cache.
    /// Call this whenever inputText changes to persist after 1 second of inactivity.
    func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: Self.saveDebounceSeconds * 1_000_000_000)
            guard !Task.isCancelled else { return }
            UserDefaults.standard.set(self.inputText, forKey: Self.cacheKey)
        }
    }

    // MARK: - Actions

    /// Load sample markdown
    func loadSample() {
        inputText = Self.sampleMarkdown
    }

    /// Clear input and cache
    func clear() {
        inputText = ""
        saveTask?.cancel()
        UserDefaults.standard.removeObject(forKey: Self.cacheKey)
    }

    /// Paste from clipboard
    func pasteFromClipboard() {
        if let string = NSPasteboard.general.string(forType: .string) {
            inputText = string
        }
    }

    /// Copy current output to clipboard
    func copyOutput() {
        let textToCopy: String
        switch outputMode {
        case .preview:
            textToCopy = htmlOutput
        case .html:
            textToCopy = htmlOutput
        case .htmlCSS:
            textToCopy = htmlWithCSSOutput
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(textToCopy, forType: .string)
    }

    /// Open in browser
    func openInBrowser() {
        let htmlContent = outputMode == .htmlCSS ? htmlWithCSSOutput : previewHTML

        // Create temporary HTML file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "markdown-preview-\(UUID().uuidString).html"
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try htmlContent.write(to: fileURL, atomically: true, encoding: .utf8)
            NSWorkspace.shared.open(fileURL)
        } catch {
            print("Failed to open in browser: \(error)")
        }
    }
}

