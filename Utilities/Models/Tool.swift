import SwiftUI

/// Represents a utility tool in the app
enum Tool: String, CaseIterable, Identifiable {
    case markdownPreview = "Markdown Preview"
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
        }
    }

    var shortcut: String? {
        switch self {
        case .markdownPreview:
            return "⌘1"
        }
    }
}

