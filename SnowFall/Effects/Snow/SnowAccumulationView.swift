import AppKit
import Combine

final class SnowAccumulationView: NSView {
    private var accumulationLayer: CAGradientLayer?
    private var cancellables = Set<AnyCancellable>()

    private var accumulationHeight: CGFloat = 0
    private let maxAccumulationHeight: CGFloat = 80
    private var accumulationTimer: Timer?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupLayers()
        bindToSettings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayers() {
        wantsLayer = true
        layer?.backgroundColor = .clear

        // Gradient for snow pile
        accumulationLayer = CAGradientLayer()
        accumulationLayer?.colors = [
            NSColor.white.withAlphaComponent(0.95).cgColor,
            NSColor.white.withAlphaComponent(0.8).cgColor,
            NSColor.white.withAlphaComponent(0.4).cgColor,
            NSColor.clear.cgColor
        ]
        accumulationLayer?.locations = [0.0, 0.3, 0.7, 1.0]
        accumulationLayer?.startPoint = CGPoint(x: 0.5, y: 0)
        accumulationLayer?.endPoint = CGPoint(x: 0.5, y: 1)
        accumulationLayer?.opacity = 0

        if let accumulationLayer = accumulationLayer {
            layer?.addSublayer(accumulationLayer)
        }
    }

    func startAccumulation() {
        guard SettingsManager.shared.accumulationEnabled else {
            stopAccumulation()
            return
        }

        accumulationHeight = 0
        accumulationLayer?.opacity = 1
        updateAccumulationFrame()

        accumulationTimer?.invalidate()
        accumulationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.incrementAccumulation()
        }
    }

    func stopAccumulation() {
        accumulationTimer?.invalidate()
        accumulationTimer = nil

        // Fade out animation
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        accumulationLayer?.opacity = 0
        CATransaction.commit()

        accumulationHeight = 0
    }

    private func incrementAccumulation() {
        guard accumulationHeight < maxAccumulationHeight else { return }

        let intensity = SettingsManager.shared.snowIntensity
        let increment = intensity / 300.0  // Slow accumulation

        accumulationHeight = min(accumulationHeight + increment, maxAccumulationHeight)
        updateAccumulationFrame()
    }

    private func updateAccumulationFrame() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.3)

        accumulationLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: accumulationHeight
        )

        CATransaction.commit()
    }

    override func layout() {
        super.layout()
        updateAccumulationFrame()
    }

    private func bindToSettings() {
        SettingsManager.shared.$accumulationEnabled
            .sink { [weak self] enabled in
                if enabled {
                    self?.startAccumulation()
                } else {
                    self?.stopAccumulation()
                }
            }
            .store(in: &cancellables)
    }

    func reset() {
        stopAccumulation()
        if SettingsManager.shared.accumulationEnabled {
            startAccumulation()
        }
    }
}
