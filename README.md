# Sedo

**Sedo** is a cross-platform motorcycle dashboard application built with Flutter for Android and iOS devices.

Designed specifically for riders, Sedo transforms a smartphone into a motorcycle-friendly dashboard that combines navigation, speed monitoring, media controls, and offline map capabilities in a clean, distraction-free interface.

The project follows an **offline-first philosophy**, allowing riders to access navigation and essential riding information even in areas with limited or no network connectivity.

---
<img src="readme_assets/test.gif" alt="Demo" width="800">



# Features

| Feature                  | Description                              |
| ------------------------ | ---------------------------------------- |
| OpenStreetMap Navigation | Interactive map powered by OpenStreetMap |
| Offline Maps             | Download map regions for offline usage   |
| GPS Tracking             | Real-time rider location tracking        |
| Digital Speedometer      | GPS-based speed monitoring               |
| Music Player             | Local music playback and controls        |
| Image Gallery            | Access and manage ride photos            |
| Dark Mode                | Night-friendly riding interface          |
| Rider Dashboard          | Unified view of maps, speed, and media   |
| Cross-Platform           | Runs on both Android and iOS             |

---

# Vision

Sedo aims to become a lightweight rider-focused alternative to traditional motorcycle infotainment systems.

Inspired by modern motorcycle TFT displays and vehicle dashboard systems, Sedo focuses on delivering:

* Navigation
* Speed monitoring
* Offline map access
* Nearby points of interest
* Music controls
* Ride information

without requiring expensive hardware or continuous internet access.

---

# Supported Platforms

| Platform | Status    |
| -------- | --------- |
| Android  | Supported |
| iOS      | Supported |

---

# Minimum Requirements

## Android

* Android 8.0 (Oreo) or later

## iOS

* iOS 13 or later

## Linux

* there will be support for linux in future

---

# Screens

* Dashboard
* Maps
* Speedometer
* Music Player
* Gallery
* Settings

---

# Roadmap

## Phase 1 — Core Dashboard

* [x] Dashboard UI
* [x] Music Player
* [x] Gallery Access
* [x] Theme Switching

## Phase 2 — Maps & Tracking

* [ ] Migrate from Google Maps to OpenStreetMap
* [ ] GPS Location Tracking
* [ ] GPS-Based Speedometer
* [ ] Live Position Marker

## Phase 3 — Offline Maps

* [ ] Regional Map Downloads
* [ ] Offline Tile Storage
* [ ] Download Manager
* [ ] Storage Management

## Phase 4 — Rider Utilities

* [ ] Nearby Petrol Pumps
* [ ] Nearby Restaurants
* [ ] Nearby Hospitals
* [ ] Nearby ATMs
* [ ] Nearby Repair Shops

## Phase 5 — Navigation

* [ ] Offline Route Calculation
* [ ] Turn-by-Turn Navigation
* [ ] Route Recalculation
* [ ] ETA Calculation

## Phase 6 — Advanced Features

* [ ] Ride Recording
* [ ] Ride History
* [ ] Distance Tracking
* [ ] Average Speed Statistics
* [ ] Weather Integration
* [ ] Maintenance Reminders
* [ ] Bluetooth Helmet Controls

---

# Architecture

```text
lib/
├── main.dart
├── models/
│   ├── ball.dart
│   ├── box.dart
│   └── drawer_page.dart
├── pages/
│   ├── first.dart
│   ├── map_page.dart
│   ├── musicplayer_page.dart
│   ├── picture.dart
│   ├── settings.dart
│   └── speedometer.dart
├── service/
│   ├── playlist_provider.dart
│   └── song_data.dart
├── themes/
│   ├── dark_mode.dart
│   ├── light_mode.dart
│   └── theme_provider.dart
└── assets/
    ├── cover/
    └── mp4/
```

---

# Planned Architecture

```text
lib/
├── core/
│   ├── constants/
│   ├── services/
│   └── utils/
├── features/
│   ├── dashboard/
│   ├── maps/
│   ├── navigation/
│   ├── speedometer/
│   ├── music/
│   ├── gallery/
│   └── settings/
├── providers/
├── themes/
└── models/
```

---

# Tech Stack

## Framework

* Flutter

## State Management

* Provider

## Maps

* flutter_map
* OpenStreetMap

## Location Services

* geolocator

## Audio

* audioplayers

## Images

* image_picker

## Offline Maps

* flutter_map_tile_caching *(planned)*

## Navigation & Routing

* OpenStreetMap
* GraphHopper *(planned)*

---

# Installation

Clone the repository:

```bash
git clone https://github.com/GranthikSom/sedo.git
cd sedo
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# Project Structure

```text
assets/
├── cover/
│   └── Album artwork
└── mp4/
    └── Audio files

lib/
├── models/
├── pages/
├── service/
├── themes/
└── main.dart
```

---

# Offline Maps (Planned)

Sedo is being developed with offline navigation in mind.

Future versions will allow users to:

* Download regions before a trip
* Access maps without internet
* Search nearby points of interest
* Navigate using GPS only
* Store maps locally on the device

Supported offline data:

* Roads
* Buildings
* Petrol Pumps
* Restaurants
* Hospitals
* ATMs
* Hotels
* Repair Shops

---

# Use Cases

### Daily Commuting

* Navigation
* Speed monitoring
* Music controls

### Long Distance Touring

* Offline maps
* Fuel stop discovery
* Route guidance

### Adventure Riding

* GPS tracking
* Offline navigation
* Remote area support

---

# Contributing

Contributions, ideas, feature requests, and pull requests are welcome.

If you would like to contribute:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Submit a pull request

---

# License

This project is released under the MIT License.

See the LICENSE file for details.

---

# Author

**Granthik Som**

GitHub: https://github.com/GranthikSom

---

### Ride Smarter. Ride Offline. Ride with Sedo.
