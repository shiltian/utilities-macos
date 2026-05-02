import SwiftUI
import Observation

/// Output mode for the markdown preview
enum MarkdownOutputMode: String, CaseIterable {
    case preview = "Preview"
    case outlookPreview = "Outlook Preview"
    case html = "HTML"
    case htmlCSS = "HTML + CSS"
}

/// State for the Markdown Preview tool
@Observable
final class MarkdownPreviewState {
    // MARK: - Properties
    var inputText: String = ""
    var outputMode: MarkdownOutputMode = .preview

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

    /// Full HTML document for Outlook preview (with inline styles)
    var outlookPreviewHTML: String {
        MarkdownConverter.toOutlookPreviewHTML(inputText)
    }

    /// HTML body content with inline styles for Outlook (for clipboard)
    var outlookHTML: String {
        MarkdownConverter.toOutlookHTML(inputText)
    }

    // MARK: - Actions

    /// Load sample markdown
    func loadSample() {
        inputText = Self.sampleMarkdown
    }

    /// Clear input
    func clear() {
        inputText = ""
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
        case .outlookPreview:
            // For Outlook Preview, use the dedicated copyForOutlook method
            copyForOutlook()
            return
        case .html:
            textToCopy = htmlOutput
        case .htmlCSS:
            textToCopy = htmlWithCSSOutput
        }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(textToCopy, forType: .string)
    }

    /// Copy Outlook-formatted HTML as rich text to clipboard
    func copyForOutlook() {
        let html = outlookHTML

        // Wrap in basic HTML structure for proper parsing
        let fullHTML = """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"></head>
        <body>\(html)</body>
        </html>
        """

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        let item = NSPasteboardItem()

        // Set HTML format
        item.setString(fullHTML, forType: .html)

        // Try to create RTF from HTML for broader compatibility
        if let htmlData = fullHTML.data(using: .utf8),
           let attrString = try? NSAttributedString(
               data: htmlData,
               options: [
                   .documentType: NSAttributedString.DocumentType.html,
                   .characterEncoding: String.Encoding.utf8.rawValue
               ],
               documentAttributes: nil
           ),
           let rtfData = try? attrString.data(
               from: NSRange(location: 0, length: attrString.length),
               documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]
           ) {
            item.setData(rtfData, forType: .rtf)
        }

        // Set plain text fallback (strip HTML tags)
        let plainText = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "\n\n+", with: "\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        item.setString(plainText, forType: .string)

        pasteboard.writeObjects([item])
    }

    /// Open in browser
    func openInBrowser() {
        let htmlContent: String
        switch outputMode {
        case .outlookPreview:
            htmlContent = outlookPreviewHTML
        case .htmlCSS:
            htmlContent = htmlWithCSSOutput
        default:
            htmlContent = previewHTML
        }

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

