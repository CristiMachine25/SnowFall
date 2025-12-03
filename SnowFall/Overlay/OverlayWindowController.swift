import AppKit
import Combine

final class OverlayWindowController {
    private var windows: [OverlayWindow] = []
    private var overlayViews: [OverlayView] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupNotifications()

        // Start overlay if enabled
        if SettingsManager.shared.isEnabled {
            showOverlay()
        }
    }

    private func setupNotifications() {
        // Listen for snow toggle
        NotificationCenter.default.publisher(for: .snowToggled)
            .sink { [weak self] _ in
                if SettingsManager.shared.isEnabled {
                    self?.showOverlay()
                } else {
                    self?.hideOverlay()
                }
            }
            .store(in: &cancellables)

        // Listen for screen configuration changes
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                if SettingsManager.shared.isEnabled {
                    self?.recreateWindows()
                }
            }
            .store(in: &cancellables)

        // Listen for space changes to ensure window stays on top
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .sink { [weak self] _ in
                self?.bringWindowsToFront()
            }
            .store(in: &cancellables)
    }

    func showOverlay() {
        hideOverlay() // Clean up existing windows

        for screen in NSScreen.screens {
            let window = OverlayWindow(for: screen)
            let overlayView = OverlayView(frame: screen.frame)

            window.contentView = overlayView
            window.orderFrontRegardless()

            windows.append(window)
            overlayViews.append(overlayView)
        }
    }

    func hideOverlay() {
        for view in overlayViews {
            view.stopEffects()
        }
        for window in windows {
            window.orderOut(nil)
        }
        windows.removeAll()
        overlayViews.removeAll()
    }

    private func recreateWindows() {
        showOverlay()
    }

    private func bringWindowsToFront() {
        for window in windows {
            window.orderFrontRegardless()
        }
    }
}
