import SwiftUI

struct MarkdownPreviewView: View {
    @State private var state = MarkdownPreviewState()

    var body: some View {
        HSplitView {
            MarkdownInputView(state: state)
                .frame(minWidth: 300)

            MarkdownOutputView(state: state)
                .frame(minWidth: 300)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Markdown Preview")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 400, height: 22, alignment: .center)
            }
        }
    }
}

#Preview {
    MarkdownPreviewView()
        .frame(width: 1000, height: 600)
}

