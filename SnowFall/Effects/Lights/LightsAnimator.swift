import Foundation

enum AnimationPattern: Int, CaseIterable {
    case chase = 0       // Traveling light
    case twinkle = 1     // Random sparkle
    case wave = 2        // Smooth wave
    case alternate = 3   // Every other
    case fadeInOut = 4   // All fade in/out together
    case random = 5      // Random on/off chaos
}

final class LightsAnimator {
    private var lights: [LightBulbLayer]
    private var timer: Timer?
    private var currentIndex: Int = 0
    private var pattern: AnimationPattern = .chase
    private var fadePhase: Double = 0

    init(lights: [LightBulbLayer]) {
        self.lights = lights
    }

    func start(speed: Double, pattern: AnimationPattern) {
        stop()
        self.pattern = pattern

        guard !lights.isEmpty else { return }

        // Reset all lights
        lights.forEach { $0.isLit = true }

        // Different intervals for different patterns
        let interval: Double
        switch pattern {
        case .chase:
            interval = 0.08 / max(speed / 3, 0.5)
        case .twinkle:
            interval = 0.15 / max(speed / 2, 0.5)
        case .wave:
            interval = 0.05 / max(speed / 3, 0.5)
        case .alternate:
            interval = 0.4 / max(speed, 0.5)
        case .fadeInOut:
            interval = 0.1 / max(speed / 2, 0.5)
        case .random:
            interval = 0.1 / max(speed, 0.5)
        }

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.animate()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil

        // Reset all lights to on
        lights.forEach { $0.isLit = true }
        currentIndex = 0
        fadePhase = 0
    }

    func updateSpeed(_ speed: Double) {
        if timer != nil {
            start(speed: speed, pattern: pattern)
        }
    }

    func updatePattern(_ newPattern: AnimationPattern) {
        pattern = newPattern
    }

    private func animate() {
        guard !lights.isEmpty else { return }

        switch pattern {
        case .chase:
            animateChase()
        case .twinkle:
            animateTwinkle()
        case .wave:
            animateWave()
        case .alternate:
            animateAlternate()
        case .fadeInOut:
            animateFadeInOut()
        case .random:
            animateRandom()
        }
    }

    private func animateChase() {
        // Create a "snake" of lit lights that moves
        let snakeLength = max(3, lights.count / 8)

        for (index, light) in lights.enumerated() {
            let distance = (index - currentIndex + lights.count) % lights.count
            light.isLit = distance < snakeLength
        }

        currentIndex = (currentIndex + 1) % lights.count
    }

    private func animateTwinkle() {
        // Random sparkling effect
        for light in lights {
            if Double.random(in: 0...1) < 0.15 {
                light.isLit.toggle()
            }
        }
    }

    private func animateWave() {
        // Smooth sinusoidal wave
        let phase = Double(currentIndex) * 0.15

        for (index, light) in lights.enumerated() {
            let lightPhase = Double(index) / Double(max(1, lights.count)) * .pi * 3
            let brightness = (sin(lightPhase + phase) + 1) / 2
            light.isLit = brightness > 0.4
        }

        currentIndex = (currentIndex + 1) % 10000
    }

    private func animateAlternate() {
        // Classic alternating pattern
        for (index, light) in lights.enumerated() {
            light.isLit = (index + currentIndex) % 2 == 0
        }
        currentIndex = (currentIndex + 1) % 2
    }

    private func animateFadeInOut() {
        // All lights fade in and out together
        fadePhase += 0.1
        let brightness = (sin(fadePhase) + 1) / 2

        for light in lights {
            light.isLit = brightness > 0.3
        }
    }

    private func animateRandom() {
        // Chaotic random pattern
        for light in lights {
            if Double.random(in: 0...1) < 0.3 {
                light.isLit = Bool.random()
            }
        }
    }
}
