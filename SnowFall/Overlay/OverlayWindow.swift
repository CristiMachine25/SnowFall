import AppKit

final class OverlayWindow: NSWindow {

    init(for screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        self.setFrame(screen.frame, display: false)
        configure()
    }

    private func configure() {
        // Transparent background
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false

        // Click-through - users can interact with apps below
        ignoresMouseEvents = true

        // Stay on top but below screen saver
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)) + 1)

        // Appear on all spaces and work with fullscreen apps
        collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .transient,
            .ignoresCycle
        ]

        // Don't show in mission control or app switcher
        isReleasedWhenClosed = false

        // Enable layer backing
        contentView?.wantsLayer = true
        contentView?.layer?.backgroundColor = .clear
    }

    // Prevent window from becoming key or main
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
