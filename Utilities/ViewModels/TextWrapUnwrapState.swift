import SwiftUI
import Observation
import AppKit

/// State management for the Text Wrap / Unwrap tool
@Observable
final class TextWrapUnwrapState {
    var inputText: String = ""
    var outputText: String = ""
    var lineWidth: Int = TextWrapConverter.defaultLineWidth

    // MARK: - Conversion Actions

    func wrap() {
        outputText = TextWrapConverter.wrap(inputText, lineWidth: lineWidth)
    }

    func unwrap() {
        outputText = TextWrapConverter.unwrap(inputText)
    }

    // MARK: - Clipboard Actions

    func copyOutput() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputText, forType: .string)
    }

    func pasteToInput() {
        if let string = NSPasteboard.general.string(forType: .string) {
            inputText = string
        }
    }

    // MARK: - Clear Actions

    func clearInput() {
        inputText = ""
    }

    func clearOutput() {
        outputText = ""
    }

    func clearAll() {
        inputText = ""
        outputText = ""
    }
}
