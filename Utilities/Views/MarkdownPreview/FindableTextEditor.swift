import SwiftUI
import AppKit

/// Custom NSTextView that auto-populates the find pasteboard with selection when Find is invoked
final class FindableNSTextView: NSTextView {
    override func performFindPanelAction(_ sender: Any?) {
        // Auto-populate find pasteboard with current selection before showing find bar
        populateFindPasteboardWithSelection()
        super.performFindPanelAction(sender)
    }

    /// Copy current selection to the find pasteboard so it appears in the find bar
    private func populateFindPasteboardWithSelection() {
        let selectedRange = self.selectedRange()
        guard selectedRange.length > 0,
              let textStorage = self.textStorage,
              selectedRange.location + selectedRange.length <= textStorage.length else {
            return
        }

        let selectedText = textStorage.attributedSubstring(from: selectedRange).string
        guard !selectedText.isEmpty else { return }

        let findPasteboard = NSPasteboard(name: .find)
        findPasteboard.clearContents()
        findPasteboard.setString(selectedText, forType: .string)
    }
}

/// A text editor with native macOS find bar support (⌘F).
/// - Find bar appears at top of editor
/// - Selected text auto-populates the search field
/// - Supports Find, Find & Replace, Find Next/Previous
struct FindableTextEditor: NSViewRepresentable {
    @Binding var text: String
    var font: NSFont = .monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)

    func makeNSView(context: Context) -> NSScrollView {
        // Create scroll view with our custom text view
        let textView = FindableNSTextView()
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        // Configure text view
        textView.delegate = context.coordinator
        textView.font = font
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false

        // Enable find bar (appears at top)
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true

        // Appearance
        textView.backgroundColor = .textBackgroundColor
        textView.textColor = .textColor
        textView.insertionPointColor = .textColor

        // Padding inside text view
        textView.textContainerInset = NSSize(width: 4, height: 8)

        // Set initial text
        textView.string = text

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? FindableNSTextView else { return }

        // Only update if text differs (avoid cursor jump)
        if textView.string != text {
            let selectedRanges = textView.selectedRanges
            textView.string = text
            textView.selectedRanges = selectedRanges
        }

        // Update font if changed
        if textView.font != font {
            textView.font = font
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text.wrappedValue = textView.string
        }
    }
}

#Preview {
    @Previewable @State var text = "Hello, World!\n\nThis is a test.\nTry ⌘F to find text."
    FindableTextEditor(text: $text)
        .frame(width: 400, height: 300)
}

