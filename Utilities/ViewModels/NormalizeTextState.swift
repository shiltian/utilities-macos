import SwiftUI
import Observation
import AppKit

@Observable
final class NormalizeTextState {
    var inputText: String = ""
    var outputText: String = ""

    func normalize() {
        outputText = TextNormalizer.normalize(inputText)
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
