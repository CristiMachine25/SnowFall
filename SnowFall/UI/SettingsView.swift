import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared

    var body: some View {
        TabView {
            snowSettingsTab
                .tabItem {
                    Label("Snow", systemImage: "snowflake")
                }

            lightsSettingsTab
                .tabItem {
                    Label("Lights", systemImage: "lightbulb.fill")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .padding()
        .frame(width: 420, height: 520)
    }

    // MARK: - Snow Settings Tab
    private var snowSettingsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Master toggle
                GroupBox {
                    Toggle("Enable Snow", isOn: $settings.isEnabled)
                        .toggleStyle(.switch)
                }

                // Intensity section
                GroupBox(label: Label("Intensity", systemImage: "cloud.snow")) {
                    VStack(spacing: 12) {
                        SliderRow(
                            title: "Snow Amount",
                            value: $settings.snowIntensity,
                            range: 5...100,
                            format: "%.0f%%"
                        )

                        SliderRow(
                            title: "Fall Speed",
                            value: $settings.fallSpeed,
                            range: 20...100,
                            format: "%.0f"
                        )
                    }
                }

                // Appearance section
                GroupBox(label: Label("Appearance", systemImage: "circle.fill")) {
                    VStack(spacing: 12) {
                        SliderRow(
                            title: "Flake Size",
                            value: $settings.flakeSize,
                            range: 5...40,
                            format: "%.0f"
                        )

                        SliderRow(
                            title: "Size Variation",
                            value: $settings.flakeSizeVariation,
                            range: 0...100,
                            format: "%.0f%%"
                        )

                        SliderRow(
                            title: "Opacity",
                            value: $settings.flakeOpacity,
                            range: 0.2...1.0,
                            format: "%.0f%%",
                            multiplier: 100
                        )
                    }
                }

                // Wind section
                GroupBox(label: Label("Wind", systemImage: "wind")) {
                    VStack(spacing: 12) {
                        SliderRow(
                            title: "Direction",
                            value: $settings.windDirection,
                            range: -180...180,
                            format: "%.0f°"
                        )

                        SliderRow(
                            title: "Strength",
                            value: $settings.windStrength,
                            range: 0...50,
                            format: "%.0f"
                        )
                    }
                }

                // Accumulation
                GroupBox(label: Label("Effects", systemImage: "square.stack.3d.down.right")) {
                    Toggle("Snow Pile-up at Bottom", isOn: $settings.accumulationEnabled)
                        .toggleStyle(.switch)
                }
            }
            .padding()
        }
    }

    // MARK: - Lights Settings Tab
    private var lightsSettingsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Position section
                GroupBox(label: Label("Position", systemImage: "rectangle.topthird.inset.filled")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Along Menu Bar", isOn: $settings.lightsMenuBar)
                            .toggleStyle(.switch)

                        Toggle("Frame Screen Edges", isOn: $settings.lightsScreenEdges)
                            .toggleStyle(.switch)
                    }
                }

                // Animation section
                GroupBox(label: Label("Animation", systemImage: "sparkles")) {
                    VStack(spacing: 12) {
                        SliderRow(
                            title: "Speed",
                            value: $settings.lightsSpeed,
                            range: 0.5...10,
                            format: "%.1fx"
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pattern")
                                .font(.subheadline)

                            Picker("", selection: $settings.lightsPattern) {
                                Text("Chase").tag(0)
                                Text("Twinkle").tag(1)
                                Text("Wave").tag(2)
                                Text("Alternate").tag(3)
                                Text("Fade").tag(4)
                                Text("Random").tag(5)
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                    }
                }

                // Bulb settings
                GroupBox(label: Label("Bulbs", systemImage: "lightbulb")) {
                    VStack(spacing: 12) {
                        SliderRow(
                            title: "Bulb Size",
                            value: $settings.bulbSize,
                            range: 3...10,
                            format: "%.0f"
                        )

                        SliderRow(
                            title: "Spacing",
                            value: $settings.bulbSpacing,
                            range: 25...80,
                            format: "%.0f"
                        )

                        SliderRow(
                            title: "Glow Intensity",
                            value: $settings.glowIntensity,
                            range: 0.3...1.5,
                            format: "%.1f"
                        )
                    }
                }

                // Colors section
                GroupBox(label: Label("Colors", systemImage: "paintpalette")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Color Preset")
                            .font(.subheadline)

                        Picker("", selection: $settings.lightsColorPreset) {
                            Text("Classic").tag(0)
                            Text("Traditional").tag(1)
                            Text("Ice").tag(2)
                            Text("Warm").tag(3)
                            Text("Golden").tag(4)
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()

                        // Color preview
                        HStack(spacing: 6) {
                            ForEach(settings.lightsColors, id: \.self) { color in
                                Circle()
                                    .fill(Color(nsColor: color))
                                    .frame(width: 22, height: 22)
                                    .shadow(color: Color(nsColor: color).opacity(0.7), radius: 4)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - About Tab
    private var aboutTab: some View {
        VStack(spacing: 20) {
            Image(systemName: "snowflake")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("SnowFall")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Version 1.0")
                .foregroundColor(.secondary)

            Divider()
                .padding(.horizontal)

            VStack(spacing: 8) {
                Text("A festive macOS app that adds")
                Text("falling snow and Christmas lights")
                Text("to your desktop.")
            }
            .foregroundColor(.secondary)

            Spacer()

            Text("Made with love for the holidays")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Slider Row Component
struct SliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String
    var multiplier: Double = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text(String(format: format, value * multiplier))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                    .frame(width: 50, alignment: .trailing)
            }

            Slider(value: $value, in: range)
        }
    }
}
