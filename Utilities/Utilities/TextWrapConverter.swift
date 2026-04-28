import Foundation

/// Utility for wrapping and unwrapping text at a given line width
enum TextWrapConverter {

    static let defaultLineWidth = 80

    /// Wraps text so that no line exceeds the given width, breaking at word boundaries.
    ///
    /// Blank lines are preserved as paragraph separators. Lines already within the
    /// width limit are left untouched. Leading whitespace (indentation) is preserved
    /// for the first resulting line of each source line.
    static func wrap(_ text: String, lineWidth: Int) -> String {
        let width = max(lineWidth, 1)
        return text
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { wrapLine(String($0), width: width) }
            .joined(separator: "\n")
    }

    /// Unwraps text by joining consecutive non-blank lines within each paragraph.
    ///
    /// Paragraphs are delimited by one or more blank lines. Within a paragraph,
    /// hard line breaks are replaced by a single space.
    static func unwrap(_ text: String) -> String {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var result: [String] = []
        var paragraph: [String] = []

        func flushParagraph() {
            if !paragraph.isEmpty {
                result.append(paragraph.joined(separator: " "))
                paragraph.removeAll()
            }
        }

        for line in lines {
            if line.allSatisfy(\.isWhitespace) {
                flushParagraph()
                result.append(line)
            } else {
                paragraph.append(line)
            }
        }
        flushParagraph()

        return result.joined(separator: "\n")
    }

    // MARK: - Private Helpers

    private static func wrapLine(_ line: String, width: Int) -> String {
        if line.count <= width {
            return line
        }

        let leadingWhitespace = String(line.prefix(while: \.isWhitespace))
        let trimmed = String(line.drop(while: \.isWhitespace))
        let words = trimmed.split(separator: " ", omittingEmptySubsequences: true).map(String.init)

        guard !words.isEmpty else { return line }

        var lines: [String] = []
        var currentLine = leadingWhitespace

        for word in words {
            if currentLine == leadingWhitespace {
                // First word on the line — always add it even if it exceeds width
                currentLine += word
            } else if currentLine.count + 1 + word.count <= width {
                currentLine += " " + word
            } else {
                lines.append(currentLine)
                currentLine = leadingWhitespace + word
            }
        }

        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        return lines.joined(separator: "\n")
    }
}
