// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SnowFall",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "SnowFall",
            path: "SnowFall",
            exclude: ["Resources/Assets.xcassets", "App/Info.plist", "App/SnowFall.entitlements"],
            sources: [
                "App/SnowFallApp.swift",
                "App/AppDelegate.swift",
                "Core/SettingsManager.swift",
                "MenuBar/MenuBarController.swift",
                "Overlay/OverlayWindow.swift",
                "Overlay/OverlayWindowController.swift",
                "Overlay/OverlayView.swift",
                "Effects/Snow/SnowEmitterLayer.swift",
                "Effects/Snow/SnowAccumulationView.swift",
                "Effects/Lights/ChristmasLightsView.swift",
                "Effects/Lights/LightBulbLayer.swift",
                "Effects/Lights/LightsAnimator.swift",
                "UI/SettingsView.swift"
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "SnowFall/App/Info.plist"])
            ]
        )
    ]
)
