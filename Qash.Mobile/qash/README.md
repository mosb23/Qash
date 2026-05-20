# Qash Mobile

Qash is a Flutter-based personal finance manager designed to help users track spending, manage budgets, monitor savings goals, and stay on top of recurring transactions.

## Overview

This repository contains the `qash` mobile application built with Flutter. The app is intended to pair with the Qash API backend to deliver a seamless financial planning and expense tracking experience.

## Key Features

- Dashboard with spending overview and account summary
- Transaction tracking and history
- Budget creation and progress visualization
- Savings goal management
- Recurring transaction scheduling
- Category management for income and expenses
- Export reports and insights

## Getting Started

### Prerequisites

- Flutter SDK installed
- A supported IDE such as Visual Studio Code or Android Studio
- A configured device or emulator for Android/iOS
- Optional: Qash API backend running locally or remotely

### Install Dependencies

From the project root:

```bash
flutter pub get
```

### Run the App

Launch the app on a connected device or emulator:

```bash
flutter run
```

### Build

Build a release version for your target platform:

```bash
flutter build apk
# or
flutter build ios
```

## Project Structure

- `lib/` - Main application source code
- `android/`, `ios/`, `windows/`, `macos/`, `linux/`, `web/` - Platform-specific build targets
- `test/` - Unit and widget tests
- `pubspec.yaml` - Flutter dependencies and metadata

## Notes

- Make sure the backend API configuration is set correctly before running the app.
- Use `flutter analyze` to check for code quality and lint issues.

## Useful Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Get Started](https://docs.flutter.dev/get-started)
- [Flutter codelabs](https://docs.flutter.dev/get-started/codelab)

---

Built with Flutter for personal finance management.
