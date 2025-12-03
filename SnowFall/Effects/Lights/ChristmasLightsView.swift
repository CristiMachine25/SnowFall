import AppKit
import Combine

final class ChristmasLightsView: NSView {
    private var lightLayers: [LightBulbLayer] = []
    private var wireLayers: [CAShapeLayer] = []
    private var animator: LightsAnimator?
    private var cancellables = Set<AnyCancellable>()

    private var spacing: CGFloat { CGFloat(SettingsManager.shared.bulbSpacing) }
    private var bulbSize: CGFloat { CGFloat(SettingsManager.shared.bulbSize) }

    // Notch detection
    private var notchWidth: CGFloat = 0
    private var hasNotch: Bool = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        detectNotch()
        bindToSettings()
        configureLights()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = .clear
    }

    private func detectNotch() {
        // Detect if this screen has a notch (MacBook Pro 14"/16" 2021+)
        if let screen = NSScreen.main {
            if #available(macOS 12.0, *) {
                let safeArea = screen.safeAreaInsets
                if safeArea.top > 0 {
                    hasNotch = true
                    // Notch is roughly 180 pixels wide, add margin
                    notchWidth = 220
                }
            }
        }
    }

    func configureLights() {
        clearLights()

        let settings = SettingsManager.shared
        let showMenuBar = settings.lightsMenuBar
        let showEdges = settings.lightsScreenEdges

        guard showMenuBar || showEdges else { return }

        if showMenuBar {
            createMenuBarLights()
        }

        if showEdges {
            createScreenEdgeLights()
        }

        startAnimation()
    }

    private func createMenuBarLights() {
        // Position lights to hang BELOW the menu bar, more visible
        let menuBarHeight: CGFloat = 25
        let hangDistance: CGFloat = 12  // How far below menu bar the lights hang
        let wireY = bounds.height - menuBarHeight  // Wire attached at menu bar level
        let bulbY = wireY - hangDistance  // Bulbs hang below

        let colors = SettingsManager.shared.lightsColors
        var colorIndex = 0

        // Calculate notch area to avoid (with extra margin)
        let screenMidX = bounds.width / 2
        let notchStartX = screenMidX - notchWidth / 2
        let notchEndX = screenMidX + notchWidth / 2

        // Create the wire path with nice drooping curves
        let wirePath = NSBezierPath()

        // Start from left edge
        wirePath.move(to: CGPoint(x: 0, y: wireY))

        var x: CGFloat = spacing / 2
        var lastX: CGFloat = 0
        var segmentStarted = true

        while x < bounds.width {
            // Check if we're entering the notch area
            if hasNotch && x > notchStartX - spacing/2 && x < notchEndX + spacing/2 {
                // Draw wire going around the notch (dip down below it)
                if segmentStarted && lastX < notchStartX {
                    // End the left segment, curve down around notch
                    let notchDropY = wireY - 35  // Drop below the notch

                    // Curve down on left side of notch
                    wirePath.line(to: CGPoint(x: notchStartX - 20, y: wireY))
                    wirePath.curve(to: CGPoint(x: notchStartX, y: notchDropY),
                                   controlPoint1: CGPoint(x: notchStartX - 10, y: wireY),
                                   controlPoint2: CGPoint(x: notchStartX - 5, y: notchDropY))

                    // Add lights going down left side of notch
                    for dropY in stride(from: wireY - 10, to: notchDropY, by: -spacing/2) {
                        let color = colors[colorIndex % colors.count]
                        let light = LightBulbLayer(
                            position: CGPoint(x: notchStartX - 5, y: dropY),
                            size: bulbSize,
                            color: color
                        )
                        layer?.addSublayer(light)
                        lightLayers.append(light)
                        colorIndex += 1
                    }

                    // Wire across bottom of notch
                    wirePath.line(to: CGPoint(x: notchEndX, y: notchDropY))

                    // Add lights under the notch
                    var underX = notchStartX + spacing/2
                    while underX < notchEndX - spacing/2 {
                        let color = colors[colorIndex % colors.count]
                        let light = LightBulbLayer(
                            position: CGPoint(x: underX, y: notchDropY - bulbSize - 3),
                            size: bulbSize,
                            color: color
                        )
                        layer?.addSublayer(light)
                        lightLayers.append(light)
                        colorIndex += 1
                        underX += spacing
                    }

                    // Curve back up on right side of notch
                    wirePath.curve(to: CGPoint(x: notchEndX + 20, y: wireY),
                                   controlPoint1: CGPoint(x: notchEndX + 5, y: notchDropY),
                                   controlPoint2: CGPoint(x: notchEndX + 10, y: wireY))

                    // Add lights going up right side of notch
                    for dropY in stride(from: notchDropY, to: wireY - 5, by: spacing/2) {
                        let color = colors[colorIndex % colors.count]
                        let light = LightBulbLayer(
                            position: CGPoint(x: notchEndX + 5, y: dropY),
                            size: bulbSize,
                            color: color
                        )
                        layer?.addSublayer(light)
                        lightLayers.append(light)
                        colorIndex += 1
                    }

                    lastX = notchEndX + 20
                }

                // Skip past notch
                x = notchEndX + spacing
                continue
            }

            // Normal light with sagging wire
            let sagAmount: CGFloat = 8

            if x > lastX {
                // Draw sagging wire to this light position
                let midX = (lastX + x) / 2
                wirePath.curve(to: CGPoint(x: x, y: wireY),
                               controlPoint1: CGPoint(x: midX, y: wireY - sagAmount),
                               controlPoint2: CGPoint(x: midX, y: wireY - sagAmount))
            }

            // Add hanging light bulb
            let color = colors[colorIndex % colors.count]
            let light = LightBulbLayer(
                position: CGPoint(x: x, y: bulbY),
                size: bulbSize,
                color: color
            )
            layer?.addSublayer(light)
            lightLayers.append(light)

            colorIndex += 1
            lastX = x
            x += spacing
            segmentStarted = true
        }

        // End wire at right edge
        wirePath.line(to: CGPoint(x: bounds.width, y: wireY))

        addWireLayer(path: wirePath)
    }

    private func createScreenEdgeLights() {
        let inset: CGFloat = 10
        let menuBarOffset: CGFloat = 30
        let colors = SettingsManager.shared.lightsColors
        var colorIndex = 0

        var positions: [CGPoint] = []

        // Bottom edge (left to right)
        var x: CGFloat = inset + spacing / 2
        while x < bounds.width - inset {
            positions.append(CGPoint(x: x, y: inset + bulbSize))
            x += spacing
        }

        // Right edge (bottom to top)
        var y: CGFloat = inset + spacing
        while y < bounds.height - menuBarOffset - spacing {
            positions.append(CGPoint(x: bounds.width - inset - bulbSize, y: y))
            y += spacing
        }

        // Left edge (top to bottom)
        y = bounds.height - menuBarOffset - spacing
        while y > inset + spacing {
            positions.append(CGPoint(x: inset + bulbSize, y: y))
            y -= spacing
        }

        // Create lights at positions
        for pos in positions {
            let color = colors[colorIndex % colors.count]
            let light = LightBulbLayer(
                position: pos,
                size: bulbSize,
                color: color
            )
            layer?.addSublayer(light)
            lightLayers.append(light)
            colorIndex += 1
        }

        // Create wire connecting them
        if positions.count > 1 {
            let wirePath = NSBezierPath()
            wirePath.move(to: positions[0])
            for i in 1..<positions.count {
                wirePath.line(to: positions[i])
            }
            addWireLayer(path: wirePath)
        }
    }

    private func addWireLayer(path: NSBezierPath) {
        let wire = CAShapeLayer()
        wire.path = path.cgPath
        wire.strokeColor = NSColor(white: 0.1, alpha: 0.95).cgColor
        wire.fillColor = nil
        wire.lineWidth = 2
        wire.lineCap = .round
        wire.lineJoin = .round

        layer?.insertSublayer(wire, at: 0)
        wireLayers.append(wire)
    }

    private func clearLights() {
        animator?.stop()
        animator = nil

        lightLayers.forEach { $0.removeFromSuperlayer() }
        lightLayers.removeAll()

        wireLayers.forEach { $0.removeFromSuperlayer() }
        wireLayers.removeAll()
    }

    private func startAnimation() {
        guard !lightLayers.isEmpty else { return }

        animator = LightsAnimator(lights: lightLayers)
        let pattern = AnimationPattern(rawValue: SettingsManager.shared.lightsPattern) ?? .chase
        animator?.start(speed: SettingsManager.shared.lightsSpeed, pattern: pattern)
    }

    func stopAnimation() {
        animator?.stop()
    }

    override func layout() {
        super.layout()
        detectNotch()
        configureLights()
    }

    private func bindToSettings() {
        NotificationCenter.default.publisher(for: .settingsChanged)
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.configureLights()
            }
            .store(in: &cancellables)
    }
}

// MARK: - NSBezierPath extension for CGPath
extension NSBezierPath {
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)

        for i in 0..<elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo, .cubicCurveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            case .quadraticCurveTo:
                path.addQuadCurve(to: points[1], control: points[0])
            @unknown default:
                break
            }
        }

        return path
    }
}
