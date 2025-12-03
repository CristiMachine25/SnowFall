import QuartzCore
import AppKit

final class LightBulbLayer: CALayer {
    private let glowLayer: CALayer
    private let bulbLayer: CAShapeLayer
    private(set) var lightColor: NSColor
    private let bulbSize: CGFloat

    var isLit: Bool = true {
        didSet {
            updateAppearance()
        }
    }

    init(position: CGPoint, size: CGFloat, color: NSColor) {
        self.lightColor = color
        self.bulbSize = size
        self.glowLayer = CALayer()
        self.bulbLayer = CAShapeLayer()

        super.init()

        self.position = position
        self.bounds = CGRect(x: 0, y: 0, width: size * 4, height: size * 4)

        setupLayers(size: size)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        if let other = layer as? LightBulbLayer {
            self.lightColor = other.lightColor
            self.bulbSize = other.bulbSize
            self.glowLayer = CALayer()
            self.bulbLayer = CAShapeLayer()
            super.init(layer: layer)
        } else {
            self.lightColor = .red
            self.bulbSize = 5
            self.glowLayer = CALayer()
            self.bulbLayer = CAShapeLayer()
            super.init(layer: layer)
        }
    }

    private func setupLayers(size: CGFloat) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let glowIntensity = CGFloat(SettingsManager.shared.glowIntensity)

        // Glow effect (larger, with shadow)
        glowLayer.bounds = CGRect(x: 0, y: 0, width: size * 2.5, height: size * 2.5)
        glowLayer.position = center
        glowLayer.backgroundColor = lightColor.withAlphaComponent(0.5 * glowIntensity).cgColor
        glowLayer.cornerRadius = size * 1.25

        // Add glow shadow
        glowLayer.shadowColor = lightColor.cgColor
        glowLayer.shadowRadius = size * glowIntensity
        glowLayer.shadowOpacity = Float(0.8 * glowIntensity)
        glowLayer.shadowOffset = .zero

        addSublayer(glowLayer)

        // Bulb shape (small colored circle)
        let bulbPath = CGPath(ellipseIn: CGRect(
            x: center.x - size / 2,
            y: center.y - size / 2,
            width: size,
            height: size
        ), transform: nil)

        bulbLayer.path = bulbPath
        bulbLayer.fillColor = lightColor.cgColor

        // White highlight
        bulbLayer.strokeColor = NSColor.white.withAlphaComponent(0.3).cgColor
        bulbLayer.lineWidth = 0.5

        addSublayer(bulbLayer)
    }

    private func updateAppearance() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.1)

        let glowIntensity = CGFloat(SettingsManager.shared.glowIntensity)

        if isLit {
            glowLayer.opacity = 1.0
            glowLayer.shadowOpacity = Float(0.8 * glowIntensity)
            bulbLayer.fillColor = lightColor.cgColor
        } else {
            glowLayer.opacity = 0.1
            glowLayer.shadowOpacity = 0.05
            bulbLayer.fillColor = lightColor.withAlphaComponent(0.2).cgColor
        }

        CATransaction.commit()
    }
}
