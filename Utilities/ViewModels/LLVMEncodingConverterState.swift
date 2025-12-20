import SwiftUI
import Observation
import AppKit

/// State management for the LLVM MC and SP3 Converter
@Observable
final class LLVMEncodingConverterState {
    /// LLVM MC encoding input text
    var llvmMcText: String = ""

    /// SP3 encoding input text
    var sp3Text: String = ""

    // MARK: - Conversion Actions

    /// Convert LLVM MC encoding to SP3 encoding
    func convertToSp3() {
        sp3Text = LLVMEncodingConverter.llvmMcToSp3(llvmMcText)
    }

    /// Convert SP3 encoding to LLVM MC encoding
    func convertToLlvmMc() {
        llvmMcText = LLVMEncodingConverter.sp3ToLlvmMc(sp3Text)
    }

    // MARK: - Clipboard Actions

    /// Copy LLVM MC text to clipboard
    func copyLlvmMc() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(llvmMcText, forType: .string)
    }

    /// Copy SP3 text to clipboard
    func copySp3() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(sp3Text, forType: .string)
    }

    /// Paste from clipboard to LLVM MC text
    func pasteToLlvmMc() {
        if let string = NSPasteboard.general.string(forType: .string) {
            llvmMcText = string
        }
    }

    /// Paste from clipboard to SP3 text
    func pasteToSp3() {
        if let string = NSPasteboard.general.string(forType: .string) {
            sp3Text = string
        }
    }

    // MARK: - Clear Actions

    /// Clear LLVM MC text
    func clearLlvmMc() {
        llvmMcText = ""
    }

    /// Clear SP3 text
    func clearSp3() {
        sp3Text = ""
    }

    /// Clear both texts
    func clearAll() {
        llvmMcText = ""
        sp3Text = ""
    }
}

