import SwiftUI
import Observation

/// Global app state using the new Observable macro (macOS 14+)
@Observable
final class AppState {
    var selectedTool: Tool = .markdownPreview
    var searchText: String = ""

    var filteredTools: [Tool] {
        if searchText.isEmpty {
            return Tool.allCases
        }
        return Tool.allCases.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

