import QuartzCore
import AppKit
import Combine

final class SnowEmitterLayer: CAEmitterLayer {
    private var cancellables = Set<AnyCancellable>()
    private let settings = SettingsManager.shared
    private var cachedSnowflakeImage: CGImage?

    override init() {
        super.init()
        setupEmitter()
        bindToSettings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    private func setupEmitter() {
        emitterShape = .line
        renderMode = .oldestLast

        // Cache the snowflake image once
        cachedSnowflakeImage = createSnowflakeImage()

        // Pre-populate with some snow
        beginTime = CACurrentMediaTime() - 3.0

        updateCells()
    }

    private func createSnowflakeImage() -> CGImage? {
        let size: CGFloat = 16  // Smaller for better performance
        let imageRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(size),
            pixelsHigh: Int(size),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!

        let context = NSGraphicsContext(bitmapImageRep: imageRep)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context

        // Draw a simple soft white circle
        NSColor.white.withAlphaComponent(0.6).setFill()
        NSBezierPath(ovalIn: NSRect(x: 1, y: 1, width: size - 2, height: size - 2)).fill()

        NSColor.white.setFill()
        NSBezierPath(ovalIn: NSRect(x: size/4, y: size/4, width: size/2, height: size/2)).fill()

        NSGraphicsContext.restoreGraphicsState()

        return imageRep.cgImage
    }

    private func createSnowflakeCell(depthScale: CGFloat, speed: CGFloat, alphaMultiplier: Float) -> CAEmitterCell {
        let cell = CAEmitterCell()

        // Reuse cached image for performance
        cell.contents = cachedSnowflakeImage

        // Birth rate - OPTIMIZED: lower values
        let intensity = settings.snowIntensity
        cell.birthRate = Float(intensity / 20.0) * Float(depthScale)

        // Lifetime - shorter for less particles on screen
        cell.lifetime = 8.0
        cell.lifetimeRange = 2.0

        // Size
        let baseSize = (settings.flakeSize / 40.0) * depthScale
        cell.scale = baseSize
        cell.scaleRange = baseSize * CGFloat(settings.flakeSizeVariation / 100.0)

        // Velocity downward
        cell.velocity = speed
        cell.velocityRange = speed * 0.2
        cell.emissionLongitude = -.pi / 2
        cell.emissionRange = .pi / 10

        // Wind
        let windForce = settings.windStrength * 1.5
        let windAngle = settings.windDirection * .pi / 180.0
        cell.xAcceleration = windForce * cos(windAngle)
        cell.yAcceleration = -8  // Gravity

        // Minimal rotation for performance
        cell.spin = 0.2
        cell.spinRange = 0.5

        // Color with alpha
        let opacity = CGFloat(settings.flakeOpacity) * CGFloat(alphaMultiplier)
        cell.color = NSColor.white.withAlphaComponent(opacity).cgColor

        return cell
    }

    func updateEmitterPosition(for bounds: CGRect) {
        emitterPosition = CGPoint(x: bounds.midX, y: bounds.height)
        emitterSize = CGSize(width: bounds.width, height: 1)
    }

    private func bindToSettings() {
        NotificationCenter.default.publisher(for: .settingsChanged)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.updateCells()
            }
            .store(in: &cancellables)
    }

    func updateCells() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let baseSpeed = settings.fallSpeed

        // Only 2 layers for better performance
        emitterCells = [
            createSnowflakeCell(depthScale: 0.6, speed: CGFloat(baseSpeed * 0.6), alphaMultiplier: 0.6),
            createSnowflakeCell(depthScale: 1.0, speed: CGFloat(baseSpeed), alphaMultiplier: 1.0),
        ]

        CATransaction.commit()
    }

    func pauseEmission() {
        birthRate = 0
    }

    func resumeEmission() {
        birthRate = 1
    }
}
