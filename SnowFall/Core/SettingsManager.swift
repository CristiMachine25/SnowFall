import Foundation
import AppKit
import Combine

extension Notification.Name {
    static let snowToggled = Notification.Name("snowToggled")
    static let settingsChanged = Notification.Name("settingsChanged")
}

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    // MARK: - Snow Settings
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
            NotificationCenter.default.post(name: .snowToggled, object: nil)
        }
    }

    @Published var snowIntensity: Double {
        didSet {
            UserDefaults.standard.set(snowIntensity, forKey: "snowIntensity")
            notifySettingsChanged()
        }
    }

    @Published var fallSpeed: Double {
        didSet {
            UserDefaults.standard.set(fallSpeed, forKey: "fallSpeed")
            notifySettingsChanged()
        }
    }

    @Published var flakeSize: Double {
        didSet {
            UserDefaults.standard.set(flakeSize, forKey: "flakeSize")
            notifySettingsChanged()
        }
    }

    @Published var flakeSizeVariation: Double {
        didSet {
            UserDefaults.standard.set(flakeSizeVariation, forKey: "flakeSizeVariation")
            notifySettingsChanged()
        }
    }

    @Published var windDirection: Double {
        didSet {
            UserDefaults.standard.set(windDirection, forKey: "windDirection")
            notifySettingsChanged()
        }
    }

    @Published var windStrength: Double {
        didSet {
            UserDefaults.standard.set(windStrength, forKey: "windStrength")
            notifySettingsChanged()
        }
    }

    @Published var flakeOpacity: Double {
        didSet {
            UserDefaults.standard.set(flakeOpacity, forKey: "flakeOpacity")
            notifySettingsChanged()
        }
    }

    @Published var accumulationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(accumulationEnabled, forKey: "accumulationEnabled")
            notifySettingsChanged()
        }
    }

    // MARK: - Lights Settings
    @Published var lightsMenuBar: Bool {
        didSet {
            UserDefaults.standard.set(lightsMenuBar, forKey: "lightsMenuBar")
            notifySettingsChanged()
        }
    }

    @Published var lightsScreenEdges: Bool {
        didSet {
            UserDefaults.standard.set(lightsScreenEdges, forKey: "lightsScreenEdges")
            notifySettingsChanged()
        }
    }

    @Published var lightsSpeed: Double {
        didSet {
            UserDefaults.standard.set(lightsSpeed, forKey: "lightsSpeed")
            notifySettingsChanged()
        }
    }

    @Published var lightsPattern: Int {
        didSet {
            UserDefaults.standard.set(lightsPattern, forKey: "lightsPattern")
            notifySettingsChanged()
        }
    }

    @Published var lightsColorPreset: Int {
        didSet {
            UserDefaults.standard.set(lightsColorPreset, forKey: "lightsColorPreset")
            notifySettingsChanged()
        }
    }

    @Published var bulbSize: Double {
        didSet {
            UserDefaults.standard.set(bulbSize, forKey: "bulbSize")
            notifySettingsChanged()
        }
    }

    @Published var bulbSpacing: Double {
        didSet {
            UserDefaults.standard.set(bulbSpacing, forKey: "bulbSpacing")
            notifySettingsChanged()
        }
    }

    @Published var glowIntensity: Double {
        didSet {
            UserDefaults.standard.set(glowIntensity, forKey: "glowIntensity")
            notifySettingsChanged()
        }
    }

    var lightsColors: [NSColor] {
        let presets: [[NSColor]] = [
            [.red, .green, .blue, .yellow, .orange],           // Classic
            [.red, .green],                                     // Traditional
            [.cyan, .white, .blue],                             // Ice
            [.magenta, .systemPink, .orange],                  // Warm
            [.yellow, .orange, NSColor(red: 1, green: 0.84, blue: 0, alpha: 1)],  // Golden
        ]
        let index = min(lightsColorPreset, presets.count - 1)
        return presets[max(0, index)]
    }

    // MARK: - Initialization
    private init() {
        // Register defaults
        UserDefaults.standard.register(defaults: [
            "isEnabled": true,
            "snowIntensity": 40.0,
            "fallSpeed": 50.0,
            "flakeSize": 15.0,
            "flakeSizeVariation": 50.0,
            "windDirection": 0.0,
            "windStrength": 8.0,
            "flakeOpacity": 0.85,
            "accumulationEnabled": false,
            "lightsMenuBar": true,
            "lightsScreenEdges": false,
            "lightsSpeed": 3.0,
            "lightsPattern": 0,
            "lightsColorPreset": 0,
            "bulbSize": 5.0,
            "bulbSpacing": 40.0,
            "glowIntensity": 0.9
        ])

        // Load saved values
        self.isEnabled = UserDefaults.standard.bool(forKey: "isEnabled")
        self.snowIntensity = UserDefaults.standard.double(forKey: "snowIntensity")
        self.fallSpeed = UserDefaults.standard.double(forKey: "fallSpeed")
        self.flakeSize = UserDefaults.standard.double(forKey: "flakeSize")
        self.flakeSizeVariation = UserDefaults.standard.double(forKey: "flakeSizeVariation")
        self.windDirection = UserDefaults.standard.double(forKey: "windDirection")
        self.windStrength = UserDefaults.standard.double(forKey: "windStrength")
        self.flakeOpacity = UserDefaults.standard.double(forKey: "flakeOpacity")
        self.accumulationEnabled = UserDefaults.standard.bool(forKey: "accumulationEnabled")
        self.lightsMenuBar = UserDefaults.standard.bool(forKey: "lightsMenuBar")
        self.lightsScreenEdges = UserDefaults.standard.bool(forKey: "lightsScreenEdges")
        self.lightsSpeed = UserDefaults.standard.double(forKey: "lightsSpeed")
        self.lightsPattern = UserDefaults.standard.integer(forKey: "lightsPattern")
        self.lightsColorPreset = UserDefaults.standard.integer(forKey: "lightsColorPreset")
        self.bulbSize = UserDefaults.standard.double(forKey: "bulbSize")
        self.bulbSpacing = UserDefaults.standard.double(forKey: "bulbSpacing")
        self.glowIntensity = UserDefaults.standard.double(forKey: "glowIntensity")
    }

    private func notifySettingsChanged() {
        NotificationCenter.default.post(name: .settingsChanged, object: nil)
    }
}
