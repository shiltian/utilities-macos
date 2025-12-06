import SwiftUI

@main
struct UtilitiesApp: App {
    @State private var appState = AppState()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1200, height: 800)
        .commands {
            SidebarCommands()
            TextEditingCommands()

            // Replace the default About menu item
            CommandGroup(replacing: .appInfo) {
                Button("About Utilities") {
                    openWindow(id: "about")
                }
            }
        }

        // About window
        Window("About Utilities", id: "about") {
            AboutView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }
}
