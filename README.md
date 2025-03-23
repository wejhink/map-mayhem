# 🌍 Map Mayhem

> An interactive geography learning game using spaced repetition to master world map locations

[![Flutter](https://img.shields.io/badge/Flutter-2.10+-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

[Installation](#installation) • [Usage](#usage) • [Features](#key-features) • [Contributing](#contributing) • [Roadmap](#roadmap)

---

## 📋 Introduction

**Map Mayhem** is a mobile-first geography learning application that transforms the traditional flashcard experience into an engaging, interactive map-based game. Using proven spaced repetition techniques, Map Mayhem helps users efficiently learn and remember country locations worldwide through dynamic interactions with an interactive world map.

### Key Features

- **Interactive World Map** - Tap, zoom, and explore a fully interactive vector map
- **Spaced Repetition Learning** - Modified FSRS algorithm optimizes your learning efficiency
- **Cross-Platform** - Seamless experience on both Android and iOS devices
- **Offline Capability** - Learn anywhere, even without an internet connection
- **Progress Tracking** - Monitor your improvement with detailed statistics
- **Customizable Learning** - Focus on specific regions or create custom country playlists
- **Dynamic Difficulty** - Adaptive challenges based on your performance

### Target Audience

- Geography enthusiasts, students, and educators
- Travelers wanting to improve their global geography knowledge
- Casual gamers looking for educational entertainment
- Anyone preparing for geography-related exams or competitions
- Users seeking a mobile, on-the-go learning tool using spaced repetition techniques

---

## 🚀 Installation

### Mobile App Users

#### Android

1. Download Map Mayhem from the [Google Play Store](#) _(Coming Soon)_
2. Install the application following on-screen instructions
3. Launch the app and start learning!

#### iOS

1. Download Map Mayhem from the [Apple App Store](#) _(Coming Soon)_
2. Install the application following on-screen instructions
3. Launch the app and start learning!

#### Web Version

Try Map Mayhem directly in your browser:

1. Visit our [web application](#) _(Coming Soon)_
2. No installation required - works on desktop and mobile browsers
3. Start learning geography instantly!

### Developers

#### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.5.3 or higher)
- [Dart](https://dart.dev/get-dart) (3.0.0 or higher)
- [Git](https://git-scm.com/downloads)
- Android Studio or VS Code with Flutter extensions

#### Setup Instructions

```bash
# Clone the repository
git clone https://github.com/yourusername/map-mayhem.git

# Navigate to project directory
cd map-mayhem

# Install dependencies
flutter pub get

# Run the app in development mode
flutter run
```

#### Web Development

To run the web version locally:

```bash
# Get dependencies
flutter pub get

# Run in web development mode
flutter run -d chrome

# Build for production
flutter build web --release --web-renderer canvaskit
```

For detailed deployment instructions to Cloudflare Pages, see [CLOUDFLARE_DEPLOYMENT.md](CLOUDFLARE_DEPLOYMENT.md).

#### Troubleshooting

- If you encounter package resolution issues, try `flutter clean` followed by `flutter pub get`
- For platform-specific build errors, ensure you have the latest Flutter SDK with `flutter upgrade`
- Check the [Flutter documentation](https://flutter.dev/docs) for platform-specific setup requirements

---

## 📱 Usage

### Getting Started

1. **Launch the app** - Open Map Mayhem on your mobile device
2. **Select a learning mode** - Choose between Practice, Challenge, or Custom modes
3. **Interact with the map** - Use intuitive touch gestures to navigate and select countries
4. **Track your progress** - Review your learning statistics and improvement over time

### Basic Gameplay

1. The app presents you with a country name to locate
2. The world map appears, allowing you to navigate and find the requested country
3. Tap on the country you believe matches the prompt
4. Receive immediate feedback on your selection
5. The app uses spaced repetition to schedule future appearances of each country based on your performance

### Touch Controls

- **Tap** - Select a country
- **Pinch** - Zoom in/out of the map
- **Drag** - Pan across the map
- **Double-tap** - Quick zoom to a specific area

---

## 🎮 Game Concept and Mechanics

### Gameplay Flow

Map Mayhem presents an interactive world map and challenges you to locate specific countries. The game dynamically adjusts to your performance:

1. A country name appears as your target
2. The map initially displays a zoomed-out view
3. As you narrow down your search, the map repositions and zooms in on the target region
4. Correct answers provide visual feedback with country highlighting and labeling
5. Incorrect guesses show the correct location to reinforce learning
6. The spaced repetition algorithm schedules countries to reappear based on your performance:
   - Countries you struggle with appear more frequently
   - Well-known countries appear less often to optimize learning time

### Advanced Features

- **Map Rotations** - Optional 90° rotations or upside-down views to enhance spatial awareness
- **Incremental Difficulty** - Dynamic zoom levels and panning adjust as you improve
- **Custom Region Focus** - Create playlists to focus on specific geographic areas
- **Challenge Modes** - Time-based challenges and competitive options for advanced users

---

## 🛠️ Technical Architecture

### Framework

Map Mayhem is built with **Flutter** using the **Dart** programming language, providing:

- Cross-platform compatibility for Android and iOS
- High-performance animations for smooth map transitions
- Responsive widget system for intuitive mobile interfaces

### Mapping and Graphics

- Vector-based map rendering using Flutter packages (flutter_svg, google_maps_flutter)
- High-resolution map assets optimized for various mobile screen sizes
- Touch-optimized interactive map with zoom, pan, and rotation gestures

### Spaced Repetition Engine

The core learning algorithm uses a modified FSRS (Free Spaced Repetition Scheduler) implementation:

- Dynamically adjusts review intervals based on performance
- Prioritizes difficult countries while spacing out well-known ones
- Configurable parameters for personalized learning pace

### Data Storage

- Local storage using Flutter plugins (shared_preferences, SQLite)
- Optional cloud synchronization for cross-device progress (Firebase)
- Efficient caching of map assets for offline usage

---

## 👥 Contributing

We welcome contributions to Map Mayhem! Whether you're fixing bugs, improving documentation, or proposing new features, your help makes this project better for everyone.

### Development Setup

Follow the [developer installation instructions](#developers) to set up your local environment.

### Contribution Guidelines

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Add tests** for any new functionality
4. **Ensure all tests pass** with `flutter test`
5. **Update documentation** as needed
6. **Submit a pull request** with a clear description of your changes

### Code Standards

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Write meaningful commit messages
- Include comments for complex logic
- Maintain test coverage for new features

### Reporting Issues

- Use the GitHub issue tracker to report bugs
- Include detailed steps to reproduce the issue
- Specify your device model and OS version
- Attach screenshots if applicable

---

## 🗺️ Roadmap

### Planned Enhancements

- **Skip Button** - Quickly bypass countries once mastered
- **Enhanced Context** - Show neighboring countries and facts after correct guesses
- **Custom Playlists** - Create and share country collections
- **Cloud Sync** - Cross-device progress synchronization
- **Multiplayer Mode** - Compete with friends in real-time geography challenges
- **Achievements System** - Unlock rewards for learning milestones

### Known Issues

- Touch precision on very small countries or islands
- Occasional rendering delays on older devices
- Handling of disputed territories and changing borders

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Map data contributors and geographic information sources
- Flutter and Dart development communities
- Early testers and feedback providers
- Educational research on spaced repetition learning techniques

---

_Map Mayhem is committed to providing an engaging, educational experience that makes learning world geography fun and effective. We continuously improve based on user feedback and educational best practices._
