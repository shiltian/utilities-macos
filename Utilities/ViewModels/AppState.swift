import SwiftUI
import Observation

/// Global app state using the new Observable macro (macOS 14+)
@MainActor
@Observable
final class AppState {
    var selectedTool: Tool = .markdownPreview
    var searchText: String = ""

    let markdownPreviewState = MarkdownPreviewState()
    let textWrapUnwrapState = TextWrapUnwrapState()
    let normalizeTextState = NormalizeTextState()
    let llvmEncodingConverterState = LLVMEncodingConverterState()

    /// Reference to app settings
    private let settings = AppSettings.shared

    /// Returns available tools filtered by search text and experimental settings
    var filteredTools: [Tool] {
        let availableTools = Tool.availableTools(includeExperimental: settings.enableExperimentalFeatures)

        if searchText.isEmpty {
            return availableTools
        }
        return availableTools.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

