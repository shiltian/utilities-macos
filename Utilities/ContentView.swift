import SwiftUI

struct ContentView: View {
    @State private var appState = AppState()

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 300)
        } detail: {
            ToolDetailView()
        }
        .navigationSplitViewStyle(.balanced)
        .environment(appState)
    }
}

#Preview {
    ContentView()
}

