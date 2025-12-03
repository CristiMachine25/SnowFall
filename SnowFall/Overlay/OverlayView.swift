import AppKit
import Combine

final class OverlayView: NSView {
    private var snowLayer: SnowEmitterLayer?
    private var accumulationView: SnowAccumulationView?
    private var lightsView: ChristmasLightsView?
    private var cancellables = Set<AnyCancellable>()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        setupEffects()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = .clear
    }

    private func setupEffects() {
        // Christmas lights (behind snow)
        lightsView = ChristmasLightsView(frame: bounds)
        if let lightsView = lightsView {
            addSubview(lightsView)
        }

        // Snow accumulation at the bottom
        accumulationView = SnowAccumulationView(frame: CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: 100
        ))
        if let accumulationView = accumulationView {
            addSubview(accumulationView)
        }

        // Snow emitter layer on top
        snowLayer = SnowEmitterLayer()
        if let snowLayer = snowLayer {
            snowLayer.frame = bounds
            snowLayer.updateEmitterPosition(for: bounds)
            layer?.addSublayer(snowLayer)
        }

        // Start accumulation if enabled
        if SettingsManager.shared.accumulationEnabled {
            accumulationView?.startAccumulation()
        }
    }

    override func layout() {
        super.layout()

        // Update snow emitter position
        snowLayer?.frame = bounds
        snowLayer?.updateEmitterPosition(for: bounds)

        // Update accumulation view
        accumulationView?.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: 100
        )

        // Update lights view
        lightsView?.frame = bounds
    }

    func stopEffects() {
        snowLayer?.pauseEmission()
        accumulationView?.stopAccumulation()
        lightsView?.stopAnimation()
    }

    func resumeEffects() {
        snowLayer?.resumeEmission()
        if SettingsManager.shared.accumulationEnabled {
            accumulationView?.startAccumulation()
        }
        lightsView?.configureLights()
    }
}
