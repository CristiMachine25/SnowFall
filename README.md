# SnowFall - EARLY ALPHA ❄️

**A magical macOS menu bar app that brings the holiday spirit to your desktop with falling snow and twinkling Christmas lights.**

<p align="center">
  <img src="https://img.shields.io/badge/Platform-macOS%2012%2B-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/Architecture-Apple%20Silicon-green?style=flat-square" alt="Architecture">
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square" alt="Swift">
  <img src="https://img.shields.io/badge/License-MIT-purple?style=flat-square" alt="License">
</p>

---

## ✨ Features

### 🌨️ Realistic Snowfall
- **GPU-accelerated particles** using Core Animation for smooth, efficient rendering
- **Multi-layer depth effect** with parallax for realistic 3D feel
- **Customizable intensity, size, and opacity**
- **Wind simulation** with adjustable direction and strength
- **Optional snow accumulation** at the bottom of your screen

### 🎄 Christmas Lights
- **Hanging lights along the menu bar** with realistic sagging wire
- **Screen edge framing** option for full festive immersion
- **Smart notch avoidance** - lights gracefully wrap around MacBook notches
- **6 animation patterns**: Chase, Twinkle, Wave, Alternate, Fade, Random
- **5 color presets**: Classic, Traditional, Ice, Warm, Golden
- **Adjustable bulb size, spacing, and glow intensity**

### 🎛️ Full Customization
- Intuitive settings panel with real-time preview
- All settings persist between sessions
- Quick controls accessible from the menu bar

### 💻 Designed for macOS
- Lives in your menu bar - no dock icon clutter
- Click-through overlay - never interferes with your work
- Works across all Spaces and fullscreen apps
- Optimized for Apple Silicon

---

## 📥 Installation

### Download Binary (Recommended)
1. Go to [Releases](../../releases)
2. Download the latest `SnowFall-arm64.zip`
3. Unzip and move `SnowFall` to your Applications folder or preferred location
4. Run the app (you may need to right-click → Open the first time)

### Build from Source
```bash
# Clone the repository
git clone https://github.com/user/SnowFall.git
cd SnowFall

# Build release binary
swift build -c release

# Run
.build/release/SnowFall
```

---

## 🚀 Usage

1. **Launch SnowFall** - Look for the ❄️ snowflake icon in your menu bar
2. **Toggle Effects** - Click the icon to enable/disable snow
3. **Customize** - Click the icon → Settings to adjust everything

### Menu Bar Options
- **Enable/Disable Snow** - Quick toggle
- **Quick Controls** - Adjust intensity and wind on the fly
- **Settings** - Full customization panel
- **Quit** - Exit the app

---

## ⚙️ Settings

### Snow Tab
| Setting | Description |
|---------|-------------|
| Snow Amount | Number of snowflakes falling |
| Fall Speed | How fast the snow falls |
| Flake Size | Base size of snowflakes |
| Size Variation | Random size variation |
| Opacity | Transparency of snowflakes |
| Wind Direction | Horizontal drift direction (-180° to 180°) |
| Wind Strength | How much the wind affects snowflakes |
| Snow Pile-up | Enable accumulation at screen bottom |

### Lights Tab
| Setting | Description |
|---------|-------------|
| Along Menu Bar | Show lights hanging from menu bar |
| Frame Screen Edges | Show lights around screen edges |
| Speed | Animation speed |
| Pattern | Chase, Twinkle, Wave, Alternate, Fade, Random |
| Bulb Size | Size of light bulbs |
| Spacing | Distance between lights |
| Glow Intensity | Brightness of the glow effect |
| Color Preset | Classic, Traditional, Ice, Warm, Golden |

---

## 🔧 System Requirements

- **macOS 12.0** (Monterey) or later
- **Apple Silicon** (M1, M2, M3, etc.)
- ~20MB disk space
- Minimal CPU/GPU usage (optimized particle system)

---

## 🏗️ Technical Details

Built with:
- **Swift 5.9** & **SwiftUI** for the settings interface
- **AppKit** for window management and menu bar integration
- **Core Animation** (`CAEmitterLayer`) for GPU-accelerated snow particles
- **Combine** for reactive settings updates

The app uses a transparent, click-through overlay window that sits above all other windows but allows full interaction with apps underneath.

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

---

## 📄 License

MIT License - Feel free to use, modify, and distribute.

---

## 🎄 Happy Holidays!

Made with ❤️ for the festive season. Enjoy the snow!
