# BehaviorMind

> Intelligent Behavioral Pattern Prediction and Holistic Health Wellness Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.35.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.0-0175C2?logo=dart)](https://dart.dev)
[![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-brightgreen)](https://flutter.dev/multi-platform)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

BehaviorMind is a privacy-first Flutter health application designed to analyze physical activity, physiological metrics, sleep architecture, and digital behavior patterns. Using on-device machine learning (TensorFlow Lite), it predicts personal behavioral rhythms, detects energy slumps, and provides actionable lifestyle insights.

---

## Key Features

### Health and Activity Monitoring
- **Real-Time Step and Movement Tracking**: Continuous pedometer and accelerometer data ingestion via `sensors_plus` and Google Health Connect / Apple HealthKit (`health`).
- **Comprehensive Daily Metrics**: Tracks distance walked, active minutes, calories burned, and real-time heart rate monitoring.
- **Historical Analysis**: Weekly and monthly trends rendered with interactive visualizations powered by `fl_chart`.

### Sleep Architecture Analysis
- **Sleep Stage Categorization**: Breakdown of Deep Sleep, Light Sleep, REM, and Awake periods.
- **Sleep Quality Scoring**: Evaluates sleep consistency and recommends optimal bedtimes based on circadian rhythm analysis.

### Predictive Behavioral Intelligence
- **On-Device AI Engine**: Runs local TensorFlow Lite (`tflite_flutter`) models directly on the smartphone for fast, offline, and private inference.
- **Day-Ahead Predictions**: Forecasts morning focus windows, afternoon slump risks, and optimal workout periods.
- **Personalized Recommendations**: Context-aware suggestions tailored to daily routines.

### Digital Wellbeing and Screen Time
- **App Usage Categorization**: Leverages native Android `usage_stats` to categorize screen time across productivity, social, finance, and entertainment applications.
- **Screen Time Correlation**: Correlates screen time with subsequent sleep latency and energy levels.

---

## Architecture and Project Structure

```
BehaviorMind/
├── android/                  # Native Android configuration (Kotlin DSL gradle)
├── ios/                      # Native iOS runner and HealthKit entitlements
├── web/                      # Web runner with CanvasKit rendering
├── windows/                  # Windows desktop native application
├── lib/
│   ├── models/               # Data models (HealthData, Activity, Sleep, Prediction, User)
│   ├── providers/            # State management with Provider (Health, Prediction, User, Settings)
│   ├── routes.dart           # Declarative application routing table
│   ├── screens/              # UI Screens (Home, Permission, SleepDetails, Archive, Profile, etc.)
│   ├── services/             # Core services (HealthService, UsageStatsService, TensorflowService)
│   ├── theme/                # Material 3 Design design tokens and color schemes
│   ├── utils/                # Date formatting, chart helpers, logging
│   └── widgets/              # Reusable UI widgets and custom charts
├── assets/                   # Vector icons (SVG) and brand images
└── test/                     # Automated unit and widget test suite
```

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.29+ / v3.35+ recommended)
- [Dart SDK](https://dart.dev/get-dart) (v3.9+)
- For Android: Android Studio with Android SDK 34+
- For Web: Google Chrome

### Installation and Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/TanmayTejaswi/BehaviorMind.git
   cd BehaviorMind
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify analyzer status**:
   ```bash
   flutter analyze
   ```

4. **Run the test suite**:
   ```bash
   flutter test
   ```

5. **Launch the application**:
   - **On Web (Chrome)**:
     ```bash
     flutter run -d chrome
     ```
   - **On Android**:
     ```bash
     flutter run -d android
     ```
   - **On Windows Desktop**:
     ```bash
     flutter run -d windows
     ```

---

## Pre-Built Release

A ready-to-install Android debug APK is built and verified:
- **Download**: Available on the [GitHub Releases](https://github.com/TanmayTejaswi/BehaviorMind/releases) page.
- Direct installation via ADB:
  ```bash
  adb install BehaviorMind-debug.apk
  ```

---

## Privacy and Permissions
BehaviorMind is engineered with privacy as a foundational principle:
- **Zero Cloud Leakage**: Health data and sensor readings are processed locally on the device.
- **Explicit Consent**: Sensitive permissions (Activity Recognition, Health Connect, Usage Stats) are requested transparently with fallback mechanisms.

---

## License
This project is licensed under the MIT License.
