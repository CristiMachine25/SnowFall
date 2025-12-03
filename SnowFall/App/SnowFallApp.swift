import SwiftUI

@main
struct SnowFallApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // We don't need a main window - this is a menu bar app
        Settings {
            EmptyView()
        }
    }
}
