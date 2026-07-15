# Sedo: Advanced Motorcycle Dashboard

Sedo is a modern, landscape-first Flutter application designed to serve as a comprehensive dashboard for your motorcycle. Built to run on a mounted tablet or smartphone, it provides riders with everything they need on the road—from turn-by-turn navigation and live speed tracking to music controls and offline map capabilities.

![Hero Screenshot Placeholder](path/to/hero_screenshot.png)

## 🌟 Key Features

### 🗺️ Turn-by-Turn Navigation & Offline Maps
* **Live Navigation:** Complete turn-by-turn routing using OSRM, featuring maneuver instructions, distance-to-turn, ETA, and arrival time.
* **Smart Camera Tracking:** The map dynamically centers on the rider's position while automatically adjusting zoom based on speed.
* **Destination Search:** Search for places online (powered by Nominatim) or drop a pin directly on the map.
* **Offline Maps:** Download specific regions (5km, 15km, or 50km radiuses) for completely offline map tile rendering.

![Map & Navigation Screenshot Placeholder](path/to/map_screenshot.png)

### 🚀 Digital Speedometer
* Real-time GPS-based speed tracking.
* Smooth, high-contrast UI designed for quick glances while riding.
* Toggleable metric and imperial units (km/h vs mph).

![Speedometer Screenshot Placeholder](path/to/speedometer_screenshot.png)

### 🎵 Smart Music Integration
* Control your device's media playback directly from the dashboard.
* **Auto Pop-out Mini Player:** A sleek mini player automatically slides up on the map screen the moment a track starts playing, allowing you to pause or skip without leaving the map.
* Dedicated fullscreen music player page.

![Music Player Screenshot Placeholder](path/to/music_screenshot.png)

### 🌤️ Interactive Dashboard & UI
* **Landscape Optimized:** Immersive, sticky-fullscreen UI designed specifically for landscape mounting.
* **Dark Mode & Themes:** Built-in dynamic theme support with high-contrast elements for daytime and night riding.
* **Quick Access Drawer:** Easy swipe access to switch between the Home dashboard, Map, Speedo, Gallery, and Settings.

![Home Dashboard Screenshot Placeholder](path/to/home_screenshot.png)

### 🔐 Firebase Authentication
* Secure login system powered by Firebase.
* Supports Google Sign-In and standard email authentication.

## 📸 Media Gallery
* Built-in gallery viewer to quickly check out photos saved to the device during your ride.

![Gallery Screenshot Placeholder](path/to/gallery_screenshot.png)

## ⚙️ Settings & Customization
* Customize distance units (Kilometers / Miles).
* Customize speed units (km/h / mph).
* Manage offline map cache (view size, clear cache, download new regions).
* Toggle route line visibility and UI components.

![Settings Screenshot Placeholder](path/to/settings_screenshot.png)

---

## 🛠️ Tech Stack & Architecture
* **Framework:** Flutter (Dart)
* **Maps:** `flutter_map` with a custom-built file caching provider (`TileCache`).
* **Routing:** OSRM (Open Source Routing Machine).
* **Geocoding:** Nominatim API.
* **Backend:** Firebase Auth.
* **State Management:** Provider (MultiProvider architecture).

## 🚀 Getting Started

1. Ensure you have Flutter ^3.10.4 installed.
2. Clone the repository.
3. Run `flutter pub get`.
4. Ensure your `firebase_options.dart` is correctly configured for your Firebase project.
5. Build and run: `flutter run` (Best experienced on a physical device in landscape mode).
