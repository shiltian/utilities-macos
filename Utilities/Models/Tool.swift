import SwiftUI

/// Represents a utility tool in the app
enum Tool: String, CaseIterable, Identifiable {
    case markdownPreview = "Markdown Preview"
    case llvmMcSp3Converter = "LLVM MC and SP3 Converter"
    // Future tools can be added here:
    // case jsonFormatter = "JSON Formatter"
    // case base64Encoder = "Base64 Encoder"
    // case hashGenerator = "Hash Generator"
    // etc.

    var id: String { rawValue }

    var displayName: String { rawValue }

    var icon: String {
        switch self {
        case .markdownPreview:
            return "doc.richtext"
        case .llvmMcSp3Converter:
            return "arrow.left.arrow.right"
        }
    }

    var shortcut: String? {
        switch self {
        case .markdownPreview:
            return "⌘1"
        case .llvmMcSp3Converter:
            return nil
        }
    }

    /// Whether this tool is experimental and requires opt-in
    var isExperimental: Bool {
        switch self {
        case .markdownPreview:
            return false
        case .llvmMcSp3Converter:
            return true
        }
    }

    /// Returns all non-experimental tools
    static var standardTools: [Tool] {
        allCases.filter { !$0.isExperimental }
    }

    /// Returns all experimental tools
    static var experimentalTools: [Tool] {
        allCases.filter { $0.isExperimental }
    }

    /// Returns available tools based on settings
    static func availableTools(includeExperimental: Bool) -> [Tool] {
        if includeExperimental {
            return allCases
        }
        return standardTools
    }
}

