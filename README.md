# Sedo - Motorcycle Dashboard App

A Flutter-based motorcycle dashboard application designed for Android 8.0 (Oreo) devices. Provides essential rider information and entertainment features in a motorcycle-friendly interface.

## Target Device

- **Phone**: Honor 7c
- **OS**: Android 8.0 (Oreo)

## Features

| Feature | Description |
|---------|-------------|
| **Google Maps** | Navigation and location display for rider orientation |
| **Speedometer** | Digital speedometer display |
| **Music Player** | Audio playback controls for rider entertainment |
| **Image Gallery** | Camera/gallery access for capturing ride moments |
| **Theme Support** | Light/Dark mode toggle for day/night riding |

## Architecture

```
lib/
├── main.dart           # App entry point with Provider setup
├── models/             # Data models (Ball, Box, DrawerPage)
├── pages/              # UI screens
│   ├── first.dart              # Main dashboard
│   ├── map_page.dart           # Google Maps
│   ├── musicplayer_page.dart   # Music player
│   ├── picture.dart            # Image gallery
│   ├── settings.dart           # App settings
│   └── speedometer.dart        # Speedometer
├── service/            # Business logic
│   ├── playlist_provider.dart  # Playlist management
│   └── song_data.dart          # Song data model
└── themes/             # Theme configuration
    ├── dark_mode.dart
    ├── light_mode.dart
    └── theme_provider.dart
```

## Tech Stack

- **Framework**: Flutter SDK ^3.10.4
- **State Management**: Provider ^6.1.5+1
- **Maps**: google_maps_flutter ^2.17.0
- **Audio**: audioplayers ^6.6.0
- **Images**: image_picker ^1.2.1

## Getting Started

```bash
# Clone the project
cd sedo

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## Dependencies

Ensure the following are configured in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  animated_splash_screen: ^1.3.0
  provider: ^6.1.5+1
  google_maps_flutter: ^2.17.0
  audioplayers: ^6.6.0
  image_picker: ^1.2.1
```

## Usage

1. **Dashboard**: Main screen with split-view showing map and controls
2. **Navigation**: Use drawer menu to access different features
3. **Music**: Load playlist from `assets/mp4/` folder
4. **Settings**: Toggle dark mode for night riding

## Assets

- `assets/cover/` - Album artwork images
- `assets/mp4/` - MP3 audio files

## License

This project is for personal/educational use.
