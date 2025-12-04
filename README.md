# Utilities

A native macOS utilities app built with SwiftUI.

## Features

### Markdown Preview
- **Real-time preview**: See your markdown rendered as you type
- **Multiple output modes**:
  - **Preview**: Live rendered HTML preview
  - **HTML**: Raw HTML output
  - **HTML + CSS**: Complete HTML with embedded styling
- **Quick actions**:
  - Paste from clipboard
  - Load sample markdown
  - Clear input
  - Copy HTML output
  - Open in browser

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later

## Installation

### Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/utilities-macos.git
   cd utilities-macos
   ```

2. Open in Xcode:
   ```bash
   open Utilities.xcodeproj
   ```

3. Build and run (⌘R)

### Direct Download

Download the latest release from the [Releases](https://github.com/yourusername/utilities-macos/releases) page.

## Architecture

The app is designed with extensibility in mind, making it easy to add new utility tools:

```
Utilities/
├── Models/
│   └── Tool.swift              # Tool definitions
├── ViewModels/
│   ├── AppState.swift          # Global app state
│   └── MarkdownPreviewState.swift
├── Views/
│   ├── SidebarView.swift       # Tool navigation
│   ├── ToolDetailView.swift    # Tool router
│   └── MarkdownPreview/        # Markdown tool views
└── Utilities/
    └── MarkdownConverter.swift # Markdown → HTML
```

## Adding New Tools

1. Add a new case to `Tool.swift`:
   ```swift
   enum Tool: String, CaseIterable, Identifiable {
       case markdownPreview = "Markdown Preview"
       case jsonFormatter = "JSON Formatter"  // New tool
   }
   ```

2. Create the tool's view and state files

3. Add the view to `ToolDetailView.swift`

## License

MIT License - see [LICENSE](LICENSE) for details.

