import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var overlayController: OverlayWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - this is a menu bar only app
        NSApp.setActivationPolicy(.accessory)

        // Initialize controllers
        menuBarController = MenuBarController()
        overlayController = OverlayWindowController()
    }

    func applicationWillTerminate(_ notification: Notification) {
        overlayController?.hideOverlay()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
