import AppKit
import SwiftUI

final class MenuBarController {
    private var statusItem: NSStatusItem?
    private var settingsWindow: NSWindow?

    init() {
        setupStatusItem()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            // Use SF Symbol for snowflake
            if let image = NSImage(systemSymbolName: "snowflake", accessibilityDescription: "SnowFall") {
                let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .medium)
                button.image = image.withSymbolConfiguration(config)
            } else {
                // Fallback: draw a simple snowflake
                button.title = "❄"
            }
            button.image?.isTemplate = true
        }

        statusItem?.menu = createMenu()
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        // Enable/Disable toggle
        let toggleTitle = SettingsManager.shared.isEnabled ? "Disable Snow" : "Enable Snow"
        let toggleItem = NSMenuItem(
            title: toggleTitle,
            action: #selector(toggleSnow),
            keyEquivalent: "s"
        )
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // Quick controls submenu
        let quickMenu = NSMenu()

        let intensityItem = NSMenuItem(title: "Intensity", action: nil, keyEquivalent: "")
        intensityItem.submenu = createIntensitySubmenu()
        quickMenu.addItem(intensityItem)

        let windItem = NSMenuItem(title: "Wind", action: nil, keyEquivalent: "")
        windItem.submenu = createWindSubmenu()
        quickMenu.addItem(windItem)

        let quickControlsItem = NSMenuItem(title: "Quick Controls", action: nil, keyEquivalent: "")
        quickControlsItem.submenu = quickMenu
        menu.addItem(quickControlsItem)

        menu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit SnowFall",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func createIntensitySubmenu() -> NSMenu {
        let menu = NSMenu()

        for intensity in [20, 40, 60, 80, 100] {
            let item = NSMenuItem(
                title: "\(intensity)%",
                action: #selector(setIntensity(_:)),
                keyEquivalent: ""
            )
            item.tag = intensity
            item.target = self
            if Int(SettingsManager.shared.snowIntensity) == intensity {
                item.state = .on
            }
            menu.addItem(item)
        }

        return menu
    }

    private func createWindSubmenu() -> NSMenu {
        let menu = NSMenu()

        let options: [(String, Double)] = [
            ("None", 0),
            ("Light Left", -15),
            ("Light Right", 15),
            ("Strong Left", -35),
            ("Strong Right", 35)
        ]

        for (title, value) in options {
            let item = NSMenuItem(
                title: title,
                action: #selector(setWind(_:)),
                keyEquivalent: ""
            )
            item.representedObject = value
            item.target = self
            menu.addItem(item)
        }

        return menu
    }

    @objc private func toggleSnow() {
        SettingsManager.shared.isEnabled.toggle()
        statusItem?.menu = createMenu()
    }

    @objc private func setIntensity(_ sender: NSMenuItem) {
        SettingsManager.shared.snowIntensity = Double(sender.tag)
        statusItem?.menu = createMenu()
    }

    @objc private func setWind(_ sender: NSMenuItem) {
        if let value = sender.representedObject as? Double {
            SettingsManager.shared.windStrength = abs(value)
            SettingsManager.shared.windDirection = value >= 0 ? 0 : 180
        }
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingView = NSHostingView(rootView: settingsView)

            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 520),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.contentView = hostingView
            settingsWindow?.title = "SnowFall Settings"
            settingsWindow?.center()
            settingsWindow?.isReleasedWhenClosed = false

            // Keep settings window on top
            settingsWindow?.level = .floating
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
