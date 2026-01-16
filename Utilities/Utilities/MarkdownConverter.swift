import Foundation
import Markdown

/// Converts Markdown to HTML using Apple's swift-markdown
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

    h1 { font-size: 2em; padding-bottom: 0.3em; border-bottom: 1px solid rgba(128, 128, 128, 0.3); }
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

    .task-list-item {
        list-style-type: none;
        margin-left: -1.5em;
    }

    .task-list-item input[type="checkbox"] {
        margin-right: 0.5em;
    }

    del {
        text-decoration: line-through;
    }
    """

    /// Convert markdown to HTML (body content only)
    static func toHTML(_ markdown: String) -> String {
        let document = Document(parsing: markdown)
        var htmlVisitor = HTMLVisitor()
        return htmlVisitor.visitDocument(document)
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

    // MARK: - Outlook-Compatible HTML

    /// Convert markdown to HTML with inline styles for Outlook (body content only)
    static func toOutlookHTML(_ markdown: String) -> String {
        let document = Document(parsing: markdown)
        var outlookVisitor = OutlookHTMLVisitor()
        return outlookVisitor.visitDocument(document)
    }

    /// Convert markdown to a full HTML document for Outlook preview
    static func toOutlookPreviewHTML(_ markdown: String) -> String {
        let bodyHTML = toOutlookHTML(markdown)
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
        </head>
        <body style="margin: 0; padding: 16px;">
        \(bodyHTML)
        </body>
        </html>
        """
    }
}

// MARK: - HTML Visitor

/// Walks the Markdown AST and generates HTML
private struct HTMLVisitor: MarkupVisitor {
    typealias Result = String

    // MARK: - Document

    mutating func defaultVisit(_ markup: any Markup) -> String {
        var result = ""
        for child in markup.children {
            result += visit(child)
        }
        return result
    }

    mutating func visitDocument(_ document: Document) -> String {
        defaultVisit(document)
    }

    // MARK: - Block Elements

    mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        "<p>\(defaultVisit(paragraph))</p>\n"
    }

    mutating func visitHeading(_ heading: Heading) -> String {
        let level = heading.level
        return "<h\(level)>\(defaultVisit(heading))</h\(level)>\n"
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        "<blockquote>\n\(defaultVisit(blockQuote))</blockquote>\n"
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        let escaped = escapeHTML(codeBlock.code)
        if let language = codeBlock.language, !language.isEmpty {
            return "<pre><code class=\"language-\(language)\">\(escaped)</code></pre>\n"
        }
        return "<pre><code>\(escaped)</code></pre>\n"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> String {
        "<hr>\n"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> String {
        html.rawHTML
    }

    // MARK: - List Elements

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        "<ul>\n\(defaultVisit(unorderedList))</ul>\n"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
        let start = orderedList.startIndex
        if start == 1 {
            return "<ol>\n\(defaultVisit(orderedList))</ol>\n"
        }
        return "<ol start=\"\(start)\">\n\(defaultVisit(orderedList))</ol>\n"
    }

    mutating func visitListItem(_ listItem: ListItem) -> String {
        if let checkbox = listItem.checkbox {
            let checked = checkbox == .checked ? " checked" : ""
            return "<li class=\"task-list-item\"><input type=\"checkbox\" disabled\(checked)>\(defaultVisit(listItem))</li>\n"
        }
        return "<li>\(defaultVisit(listItem))</li>\n"
    }

    // MARK: - Table Elements

    mutating func visitTable(_ table: Table) -> String {
        "<table>\n\(defaultVisit(table))</table>\n"
    }

    mutating func visitTableHead(_ tableHead: Table.Head) -> String {
        "<thead>\n<tr>\n\(defaultVisit(tableHead))</tr>\n</thead>\n"
    }

    mutating func visitTableBody(_ tableBody: Table.Body) -> String {
        if tableBody.childCount == 0 {
            return ""
        }
        return "<tbody>\n\(defaultVisit(tableBody))</tbody>\n"
    }

    mutating func visitTableRow(_ tableRow: Table.Row) -> String {
        "<tr>\n\(defaultVisit(tableRow))</tr>\n"
    }

    mutating func visitTableCell(_ tableCell: Table.Cell) -> String {
        let tag = tableCell.parent is Table.Head ? "th" : "td"

        // Find column index by position in parent
        var columnIndex = 0
        if let parent = tableCell.parent {
            for (index, child) in parent.children.enumerated() {
                if child.range?.lowerBound == tableCell.range?.lowerBound {
                    columnIndex = index
                    break
                }
            }
        }

        // Get alignment from table
        var alignment = ""
        if let table = tableCell.parent?.parent as? Table,
           columnIndex < table.columnAlignments.count,
           let columnAlignment = table.columnAlignments[columnIndex] {
            switch columnAlignment {
            case .left:
                alignment = " style=\"text-align: left;\""
            case .center:
                alignment = " style=\"text-align: center;\""
            case .right:
                alignment = " style=\"text-align: right;\""
            }
        }

        return "<\(tag)\(alignment)>\(defaultVisit(tableCell))</\(tag)>\n"
    }

    // MARK: - Inline Elements

    mutating func visitText(_ text: Text) -> String {
        escapeHTML(text.string)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        "<em>\(defaultVisit(emphasis))</em>"
    }

    mutating func visitStrong(_ strong: Strong) -> String {
        "<strong>\(defaultVisit(strong))</strong>"
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
        "<del>\(defaultVisit(strikethrough))</del>"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
        "<code>\(escapeHTML(inlineCode.code))</code>"
    }

    mutating func visitLink(_ link: Link) -> String {
        let title = link.title.map { " title=\"\(escapeHTML($0))\"" } ?? ""
        return "<a href=\"\(escapeHTML(link.destination ?? ""))\"\(title)>\(defaultVisit(link))</a>"
    }

    mutating func visitImage(_ image: Image) -> String {
        let alt = escapeHTML(image.plainText)
        let src = escapeHTML(image.source ?? "")
        let title = image.title.map { " title=\"\(escapeHTML($0))\"" } ?? ""
        return "<img src=\"\(src)\" alt=\"\(alt)\"\(title)>"
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
        "\n"
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
        "<br>\n"
    }

    mutating func visitInlineHTML(_ html: InlineHTML) -> String {
        html.rawHTML
    }

    mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> String {
        if let destination = symbolLink.destination {
            return "<code>\(escapeHTML(destination))</code>"
        }
        return ""
    }

    // MARK: - Helpers

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

// MARK: - Outlook HTML Visitor

/// Walks the Markdown AST and generates HTML with inline styles for Outlook compatibility
private struct OutlookHTMLVisitor: MarkupVisitor {
    typealias Result = String

    // MARK: - Style Constants

    private enum Styles {
        static let fontFamily = "'Aptos', 'Calibri', Arial, sans-serif"
        static let codeFontFamily = "Consolas, 'Courier New', monospace"
        static let fontSize = "12pt"
        static let codeFontSize = "11pt"
        static let lineHeight = "1.08"
        static let textColor = "#000000"

        static let paragraphStyle = "font-family: \(fontFamily); font-size: \(fontSize); line-height: \(lineHeight); margin: 0 0 3pt 0; color: \(textColor);"
        static let listStyle = "font-family: \(fontFamily); font-size: \(fontSize); line-height: \(lineHeight); margin: 0 0 2pt 0; padding-left: 31pt; color: \(textColor);"
        static let listItemStyle = "margin: 0;"
        static let codeBlockStyle = "font-family: \(codeFontFamily); font-size: \(codeFontSize); line-height: 1.4; background-color: #f5f5f5; padding: 12pt; margin: 4pt 0 4pt 0; border: 1px solid #e0e0e0; border-radius: 4px; white-space: pre-wrap;"
        static let inlineCodeStyle = "font-family: \(codeFontFamily); font-size: \(codeFontSize); background-color: #f0f0f0; padding: 2px 4px; border-radius: 3px;"
        static let blockquoteStyle = "font-family: \(fontFamily); font-size: \(fontSize); line-height: \(lineHeight); margin: 0 0 3pt 0; padding: 0 0 0 12pt; border-left: 3px solid #e0e0e0; color: #666666;"
        static let linkColor = "#0969da"
        static let tableStyle = "border-collapse: collapse; margin: 4pt 0 4pt 0;"
        static let tableCellStyle = "font-family: \(fontFamily); font-size: \(fontSize); padding: 6pt 12pt; border: 1px solid #e0e0e0;"
        static let tableHeaderStyle = "font-family: \(fontFamily); font-size: \(fontSize); padding: 6pt 12pt; border: 1px solid #e0e0e0; font-weight: 600; background-color: #f5f5f5;"
    }

    // MARK: - Document

    mutating func defaultVisit(_ markup: any Markup) -> String {
        var result = ""
        for child in markup.children {
            result += visit(child)
        }
        return result
    }

    mutating func visitDocument(_ document: Document) -> String {
        defaultVisit(document)
    }

    // MARK: - Block Elements

    mutating func visitParagraph(_ paragraph: Paragraph) -> String {
        "<p style=\"\(Styles.paragraphStyle)\">\(defaultVisit(paragraph))</p>\n"
    }

    mutating func visitHeading(_ heading: Heading) -> String {
        // Render headings as bold paragraphs for Outlook compatibility
        "<p style=\"\(Styles.paragraphStyle)\"><strong style=\"font-weight: 600;\">\(defaultVisit(heading))</strong></p>\n"
    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> String {
        "<div style=\"\(Styles.blockquoteStyle)\">\(defaultVisit(blockQuote))</div>\n"
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> String {
        let escaped = escapeHTML(codeBlock.code)
        return "<pre style=\"\(Styles.codeBlockStyle)\"><code style=\"font-family: inherit; font-size: inherit;\">\(escaped)</code></pre>\n"
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> String {
        "<hr style=\"border: 0; border-top: 1px solid #e0e0e0; margin: 8pt 0;\">\n"
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> String {
        html.rawHTML
    }

    // MARK: - List Elements

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> String {
        "<ul style=\"\(Styles.listStyle)\">\n\(defaultVisit(unorderedList))</ul>\n"
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> String {
        let start = orderedList.startIndex
        if start == 1 {
            return "<ol style=\"\(Styles.listStyle)\">\n\(defaultVisit(orderedList))</ol>\n"
        }
        return "<ol start=\"\(start)\" style=\"\(Styles.listStyle)\">\n\(defaultVisit(orderedList))</ol>\n"
    }

    mutating func visitListItem(_ listItem: ListItem) -> String {
        if let checkbox = listItem.checkbox {
            let checked = checkbox == .checked ? "☑" : "☐"
            return "<li style=\"\(Styles.listItemStyle)\">\(checked) \(defaultVisit(listItem))</li>\n"
        }
        return "<li style=\"\(Styles.listItemStyle)\">\(defaultVisit(listItem))</li>\n"
    }

    // MARK: - Table Elements

    mutating func visitTable(_ table: Table) -> String {
        "<table style=\"\(Styles.tableStyle)\">\n\(defaultVisit(table))</table>\n"
    }

    mutating func visitTableHead(_ tableHead: Table.Head) -> String {
        "<thead>\n<tr>\n\(defaultVisit(tableHead))</tr>\n</thead>\n"
    }

    mutating func visitTableBody(_ tableBody: Table.Body) -> String {
        if tableBody.childCount == 0 {
            return ""
        }
        return "<tbody>\n\(defaultVisit(tableBody))</tbody>\n"
    }

    mutating func visitTableRow(_ tableRow: Table.Row) -> String {
        "<tr>\n\(defaultVisit(tableRow))</tr>\n"
    }

    mutating func visitTableCell(_ tableCell: Table.Cell) -> String {
        let isHeader = tableCell.parent is Table.Head
        let style = isHeader ? Styles.tableHeaderStyle : Styles.tableCellStyle
        let tag = isHeader ? "th" : "td"

        // Find column index by position in parent
        var columnIndex = 0
        if let parent = tableCell.parent {
            for (index, child) in parent.children.enumerated() {
                if child.range?.lowerBound == tableCell.range?.lowerBound {
                    columnIndex = index
                    break
                }
            }
        }

        // Get alignment from table
        var alignmentStyle = ""
        if let table = tableCell.parent?.parent as? Table,
           columnIndex < table.columnAlignments.count,
           let columnAlignment = table.columnAlignments[columnIndex] {
            switch columnAlignment {
            case .left:
                alignmentStyle = " text-align: left;"
            case .center:
                alignmentStyle = " text-align: center;"
            case .right:
                alignmentStyle = " text-align: right;"
            }
        }

        return "<\(tag) style=\"\(style)\(alignmentStyle)\">\(defaultVisit(tableCell))</\(tag)>\n"
    }

    // MARK: - Inline Elements

    mutating func visitText(_ text: Text) -> String {
        escapeHTML(text.string)
    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> String {
        "<em style=\"font-style: italic;\">\(defaultVisit(emphasis))</em>"
    }

    mutating func visitStrong(_ strong: Strong) -> String {
        "<strong style=\"font-weight: 600;\">\(defaultVisit(strong))</strong>"
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> String {
        "<del style=\"text-decoration: line-through;\">\(defaultVisit(strikethrough))</del>"
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> String {
        "<code style=\"\(Styles.inlineCodeStyle)\">\(escapeHTML(inlineCode.code))</code>"
    }

    mutating func visitLink(_ link: Link) -> String {
        let title = link.title.map { " title=\"\(escapeHTML($0))\"" } ?? ""
        return "<a href=\"\(escapeHTML(link.destination ?? ""))\" style=\"color: \(Styles.linkColor); text-decoration: none;\"\(title)>\(defaultVisit(link))</a>"
    }

    mutating func visitImage(_ image: Image) -> String {
        let alt = escapeHTML(image.plainText)
        let src = escapeHTML(image.source ?? "")
        let title = image.title.map { " title=\"\(escapeHTML($0))\"" } ?? ""
        return "<img src=\"\(src)\" alt=\"\(alt)\"\(title) style=\"max-width: 100%;\">"
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> String {
        "\n"
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> String {
        "<br>\n"
    }

    mutating func visitInlineHTML(_ html: InlineHTML) -> String {
        html.rawHTML
    }

    mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> String {
        if let destination = symbolLink.destination {
            return "<code style=\"\(Styles.inlineCodeStyle)\">\(escapeHTML(destination))</code>"
        }
        return ""
    }

    // MARK: - Helpers

    private func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
