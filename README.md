# SafeSight - Campus Safety App

A Flutter-based campus safety application with Life360-like features and a surveillance-cam inspired dark neon aesthetic.

## Features

### 🎨 Visual Theme
- **Pure black background** (#000000) throughout - surveillance-cam vibe
- **Neon green primary** (#39FF14) for active tabs/icons/labels
- **SOS red button** (#FF1A1A) with soft outer glow
- **Typography**: ALL CAPS for tab labels with neon glow effects
- **Icons**: Simple line icons from Material Icons

### 🧭 Navigation
- **Bottom navigation bar** with 5 items: MAP, REPORT, SOS, CIRCLE, RESOURCES
- **Floating SOS button** (centered, circular, glowing red)
- **Per-tab accent colors**:
  - MAP: #39FF14 (neon green)
  - REPORT: #FF8C1A (neon orange) 
  - SOS: #FF1A1A (red)
  - CIRCLE: #27F3E3 (neon cyan)
  - RESOURCES: #39FF14 (neon green)

### 📱 Pages

#### MapPage
- Black container placeholder for future map integration

#### ReportPage
- Placeholder for incident reporting functionality

#### CirclePage
- Placeholder for safety circle/contacts features

#### ResourcesPage
- **Resources Section**:
  - Campus Security (tap-to-call: `tel:+0000000000`)
  - AED / First Aid Info
  - Blue-Light Phones
- **Profile/Settings Section**:
  - Safe Word setup
  - Privacy toggles
  - Notifications settings
  - Campus Verification

#### SOS Fullscreen
- **Giant red SOS button** with glow effect
- **Haptic feedback** on activation
- **10-second countdown** with auto-activation
- **Black background** for emergency focus

## 🏗️ Architecture

```
lib/
├── main.dart              # App entry point, theme, navigation scaffold
└── pages/
    ├── map_page.dart      # Map view (placeholder)
    ├── report_page.dart   # Incident reporting (placeholder)  
    ├── circle_page.dart   # Safety circle (placeholder)
    ├── resources_page.dart # Resources and settings
    └── sos_fullscreen.dart # Emergency SOS screen
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.0+
- Dart 3.0.0+

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd SafeSight
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # On Android emulator
   flutter run -d android
   
   # On iOS simulator  
   flutter run -d ios
   
   # On web browser
   flutter run -d chrome
   
   # On Windows (requires Visual Studio)
   flutter run -d windows
   ```

## 📦 Dependencies

- **flutter**: SDK
- **url_launcher**: ^6.2.2 (for tap-to-call functionality)
- **cupertino_icons**: ^1.0.6

## ✨ Key Features Implemented

✅ **Neon-themed UI** with surveillance aesthetic  
✅ **Bottom navigation** with 5 tabs and floating SOS  
✅ **Per-tab accent colors** with glow effects  
✅ **Tap-to-call functionality** for Campus Security  
✅ **SOS emergency screen** with haptic feedback  
✅ **Material Design icons** (no external packages)  
✅ **Responsive layout** works on all platforms  
✅ **Complete navigation flow** between all screens

## 🎯 Acceptance Criteria Met

- ✅ Running `flutter run` shows bottom bar with 5 items
- ✅ Center SOS button is larger and glows red
- ✅ Tapping tabs switches pages with neon colors
- ✅ Active items show neon color + ALL CAPS labels
- ✅ Inactive items are #6E6E6E
- ✅ Resources page shows actionable list items
- ✅ Campus Security triggers `tel:` URL launch
- ✅ SOS button opens full-screen emergency page
- ✅ All widgets compile and run successfully

## 🔮 Future Enhancements

- Real-time location tracking and sharing
- Integration with campus security systems  
- Push notifications for safety alerts
- Map integration with emergency locations
- User authentication and profiles
- Incident reporting with photo/video
- Safety circle management
- Geofencing and safe zone alerts

---

**Built for campus safety hackathon** 🏫🛡️
