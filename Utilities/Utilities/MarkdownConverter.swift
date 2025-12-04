import Foundation

/// Converts Markdown to HTML
enum MarkdownConverter {

    /// GitHub Markdown CSS styling (no explicit backgrounds for dark/light compatibility)
    static let defaultCSS = """
    :root {
        color-scheme: light dark;
    }

    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif;
        font-size: 16px;
        line-height: 1.5;
        word-wrap: break-word;
        padding: 24px;
        max-width: 100%;
        margin: 0 auto;
    }

    h1, h2, h3, h4, h5, h6 {
        margin-top: 24px;
        margin-bottom: 16px;
        font-weight: 600;
        line-height: 1.25;
    }

    h1 { font-size: 2em; padding-bottom: 0.3em; border-bottom: 1px solid currentColor; opacity: 0.3; }
    h1 { opacity: 1; border-bottom: 1px solid rgba(128, 128, 128, 0.3); }
    h2 { font-size: 1.5em; padding-bottom: 0.3em; border-bottom: 1px solid rgba(128, 128, 128, 0.3); }
    h3 { font-size: 1.25em; }
    h4 { font-size: 1em; }
    h5 { font-size: 0.875em; }
    h6 { font-size: 0.85em; opacity: 0.7; }

    p { margin-top: 0; margin-bottom: 16px; }

    a { color: #0969da; text-decoration: none; }
    a:hover { text-decoration: underline; }
    @media (prefers-color-scheme: dark) {
        a { color: #4493f8; }
    }

    strong { font-weight: 600; }

    code {
        font-family: ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace;
        font-size: 85%;
        padding: 0.2em 0.4em;
        margin: 0;
        border-radius: 6px;
        white-space: break-spaces;
        border: 1px solid rgba(128, 128, 128, 0.3);
    }

    pre {
        font-family: ui-monospace, SFMono-Regular, 'SF Mono', Menlo, Consolas, 'Liberation Mono', monospace;
        font-size: 85%;
        padding: 16px;
        overflow: auto;
        line-height: 1.45;
        border-radius: 6px;
        margin-top: 0;
        margin-bottom: 16px;
        border: 1px solid rgba(128, 128, 128, 0.3);
    }

    pre code {
        display: inline;
        max-width: auto;
        padding: 0;
        margin: 0;
        overflow: visible;
        line-height: inherit;
        word-wrap: normal;
        border: 0;
        font-size: 100%;
        white-space: pre;
    }

    blockquote {
        margin: 0 0 16px 0;
        padding: 0 1em;
        opacity: 0.7;
        border-left: 0.25em solid rgba(128, 128, 128, 0.5);
    }

    blockquote > :first-child { margin-top: 0; }
    blockquote > :last-child { margin-bottom: 0; }

    ul, ol {
        padding-left: 2em;
        margin-top: 0;
        margin-bottom: 16px;
    }

    ul ul, ul ol, ol ol, ol ul {
        margin-top: 0;
        margin-bottom: 0;
    }

    li { margin-top: 0.25em; }
    li > p { margin-top: 16px; }
    li + li { margin-top: 0.25em; }

    hr {
        height: 1px;
        padding: 0;
        margin: 24px 0;
        border: 0;
        border-top: 1px solid rgba(128, 128, 128, 0.3);
    }

    table {
        border-spacing: 0;
        border-collapse: collapse;
        margin-top: 0;
        margin-bottom: 16px;
        display: block;
        width: max-content;
        max-width: 100%;
        overflow: auto;
    }

    table th {
        font-weight: 600;
        padding: 6px 13px;
        border: 1px solid rgba(128, 128, 128, 0.3);
    }

    table td {
        padding: 6px 13px;
        border: 1px solid rgba(128, 128, 128, 0.3);
    }

    table tr {
        border-top: 1px solid rgba(128, 128, 128, 0.3);
    }

    img {
        max-width: 100%;
        height: auto;
        box-sizing: content-box;
    }
    """

    /// Convert markdown to HTML (body content only)
    static func toHTML(_ markdown: String) -> String {
        var html = markdown

        // Process code blocks first (to avoid conflicts with other patterns)
        html = processCodeBlocks(html)

        // Process inline code
        html = processInlineCode(html)

        // Process headers
        html = processHeaders(html)

        // Process bold and italic
        html = processBoldItalic(html)

        // Process links
        html = processLinks(html)

        // Process blockquotes
        html = processBlockquotes(html)

        // Process lists
        html = processLists(html)

        // Process horizontal rules
        html = processHorizontalRules(html)

        // Process paragraphs
        html = processParagraphs(html)

        return html
    }

    /// Convert markdown to HTML with embedded CSS
    static func toHTMLWithCSS(_ markdown: String) -> String {
        let bodyHTML = toHTML(markdown)
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
        \(defaultCSS)
            </style>
        </head>
        <body>
        \(bodyHTML)
        </body>
        </html>
        """
    }

    /// Convert markdown to a full HTML document for preview
    static func toPreviewHTML(_ markdown: String) -> String {
        toHTMLWithCSS(markdown)
    }

    // MARK: - Private Processing Methods

    private static func processCodeBlocks(_ text: String) -> String {
        let pattern = "```(\\w*)\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }

        let range = NSRange(text.startIndex..., in: text)
        var result = text

        let matches = regex.matches(in: text, options: [], range: range).reversed()
        for match in matches {
            if let fullRange = Range(match.range, in: result),
               let codeRange = Range(match.range(at: 2), in: result) {
                let code = String(result[codeRange])
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                let replacement = "<pre><code>\(code)</code></pre>"
                result.replaceSubrange(fullRange, with: replacement)
            }
        }

        return result
    }

    private static func processInlineCode(_ text: String) -> String {
        let pattern = "`([^`]+)`"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text
        }

        let range = NSRange(text.startIndex..., in: text)
        var result = text

        let matches = regex.matches(in: text, options: [], range: range).reversed()
        for match in matches {
            if let fullRange = Range(match.range, in: result),
               let codeRange = Range(match.range(at: 1), in: result) {
                let code = String(result[codeRange])
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                result.replaceSubrange(fullRange, with: "<code>\(code)</code>")
            }
        }

        return result
    }

    private static func processHeaders(_ text: String) -> String {
        var result = text

        // H6 to H1 (process longer patterns first)
        for level in (1...6).reversed() {
            let pattern = "^#{" + String(level) + "}\\s+(.+?)\\s*#*$"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .anchorsMatchLines) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(
                    in: result,
                    options: [],
                    range: range,
                    withTemplate: "<h\(level)>$1</h\(level)>"
                )
            }
        }

        return result
    }

    private static func processBoldItalic(_ text: String) -> String {
        var result = text

        // Bold: **text** or __text__
        if let regex = try? NSRegularExpression(pattern: "\\*\\*(.+?)\\*\\*|__(.+?)__", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "<strong>$1$2</strong>")
        }

        // Italic: *text* or _text_
        if let regex = try? NSRegularExpression(pattern: "\\*(.+?)\\*|_(.+?)_", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "<em>$1$2</em>")
        }

        return result
    }

    private static func processLinks(_ text: String) -> String {
        var result = text

        // Links: [text](url)
        if let regex = try? NSRegularExpression(pattern: "\\[(.+?)\\]\\((.+?)\\)", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "<a href=\"$2\">$1</a>")
        }

        return result
    }

    private static func processBlockquotes(_ text: String) -> String {
        var lines = text.components(separatedBy: "\n")
        var inBlockquote = false
        var result: [String] = []

        for line in lines {
            if line.hasPrefix(">") {
                let content = String(line.dropFirst()).trimmingCharacters(in: .whitespaces)
                if !inBlockquote {
                    result.append("<blockquote>")
                    inBlockquote = true
                }
                if content.isEmpty {
                    result.append("<br>")
                } else {
                    result.append(content)
                }
            } else {
                if inBlockquote {
                    result.append("</blockquote>")
                    inBlockquote = false
                }
                result.append(line)
            }
        }

        if inBlockquote {
            result.append("</blockquote>")
        }

        return result.joined(separator: "\n")
    }

    private static func processLists(_ text: String) -> String {
        var lines = text.components(separatedBy: "\n")
        var result: [String] = []
        var inUnorderedList = false
        var inOrderedList = false

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Unordered list: * item, - item, + item
            if trimmed.hasPrefix("* ") || trimmed.hasPrefix("- ") || trimmed.hasPrefix("+ ") {
                if inOrderedList {
                    result.append("</ol>")
                    inOrderedList = false
                }
                if !inUnorderedList {
                    result.append("<ul>")
                    inUnorderedList = true
                }
                let content = String(trimmed.dropFirst(2))
                result.append("<li>\(content)</li>")
            }
            // Ordered list: 1. item
            else if let regex = try? NSRegularExpression(pattern: "^\\d+\\.\\s+(.+)$", options: []),
                    let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(trimmed.startIndex..., in: trimmed)),
                    let contentRange = Range(match.range(at: 1), in: trimmed) {
                if inUnorderedList {
                    result.append("</ul>")
                    inUnorderedList = false
                }
                if !inOrderedList {
                    result.append("<ol>")
                    inOrderedList = true
                }
                let content = String(trimmed[contentRange])
                result.append("<li>\(content)</li>")
            }
            else {
                if inUnorderedList {
                    result.append("</ul>")
                    inUnorderedList = false
                }
                if inOrderedList {
                    result.append("</ol>")
                    inOrderedList = false
                }
                result.append(line)
            }
        }

        if inUnorderedList {
            result.append("</ul>")
        }
        if inOrderedList {
            result.append("</ol>")
        }

        return result.joined(separator: "\n")
    }

    private static func processHorizontalRules(_ text: String) -> String {
        var result = text

        // Horizontal rule: ---, ***, ___
        if let regex = try? NSRegularExpression(pattern: "^(---+|\\*\\*\\*+|___+)$", options: .anchorsMatchLines) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "<hr>")
        }

        return result
    }

    private static func processParagraphs(_ text: String) -> String {
        let blocks = text.components(separatedBy: "\n\n")
        var result: [String] = []

        for block in blocks {
            let trimmed = block.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                continue
            }

            // Don't wrap already-wrapped HTML elements
            if trimmed.hasPrefix("<h") ||
               trimmed.hasPrefix("<ul") ||
               trimmed.hasPrefix("<ol") ||
               trimmed.hasPrefix("<blockquote") ||
               trimmed.hasPrefix("<pre") ||
               trimmed.hasPrefix("<hr") {
                result.append(trimmed)
            } else {
                // Wrap in paragraph, replace single newlines with <br>
                let withBreaks = trimmed.replacingOccurrences(of: "\n", with: "<br>\n")
                result.append("<p>\(withBreaks)</p>")
            }
        }

        return result.joined(separator: "\n\n")
    }
}

