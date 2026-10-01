# Voatmean Mobile (វត្តមាន) — Flutter Client

A cross-platform mobile application for secondary and high school attendance management and academic score computation. Built with Flutter and Dart following a unified **MVVM + Clean Architecture** pattern.

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Key Features](#key-features)
4. [Prerequisites & Environment Setup](#prerequisites--environment-setup)
5. [How to Run the Application](#how-to-run-the-application)
6. [Building the APK](#building-the-apk)
7. [Testing & Code Quality](#testing--code-quality)

---

## Architecture Overview

The application follows a consistent **Clean Architecture / Model-View-ViewModel (MVVM)** pattern powered by `provider`:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (Screens, Modals, Shared Widgets, Design System)     │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                   State & Service Layer                │
│    (ThemeProvider, LocaleProvider, AuthService,        │
│          AdminService, TeacherService)                 │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                  Core & Network Layer                  │
│    (ApiService [Dio + CookieJar], AppTheme,            │
│       AppTypography, AppColors, AppTranslations)       │
└───────────────────────────┬────────────────────────────┘
                            │ HTTP / REST (JWT Cookies)
                            ▼
               Voatmean Express Backend API
```

### Architectural Highlights
- **Single Consistent State Management**: Standardized entirely on `provider` (`ThemeProvider`, `LocaleProvider`) with reactive state binding.
- **Service-Oriented Decoupling**: Business logic, API calls, and local storage access reside in dedicated services (`AuthService`, `AdminService`, `TeacherService`). Screens contain zero direct network calls.
- **Zero Dead Boilerplate**: All unused starter templates and dead BLoC boilerplate have been pruned; 100% of files participate in active app workflows.
- **Persistent Local Preferences**: Theme mode, active locale, and notification settings persist via `shared_preferences`.

---

## Project Structure

```
mobile/
├── android/                   # Native Android configuration, Gradle, google-services.json
├── ios/                       # Native iOS project & Runner configuration
├── lib/
│   ├── core/                  # Shared cross-cutting modules
│   │   ├── constants/         # AppColors, AppTypography
│   │   ├── localization/      # AppTranslations, LocaleProvider (Khmer & English)
│   │   ├── services/          # ApiService (Singleton Dio + Persistent Cookie Jar)
│   │   ├── theme/             # AppTheme (Light & Dark), ThemeProvider
│   │   └── widgets/           # Reusable components (CustomButton, CustomTextField)
│   ├── features/              # Feature modules (Domain-driven packaging)
│   │   ├── admin/             # Admin portal
│   │   │   ├── data/          # AdminService, AdminModels
│   │   │   └── presentation/  # AdminDashboard, AssignClass, AssignTeacher,
│   │   │                      # AdminStudents, AdminSettings, AdminModals
│   │   ├── auth/              # Authentication & Session
│   │   │   ├── data/          # AuthService
│   │   │   └── presentation/  # LoginScreen, LoginForm, RoleSelectionModal
│   │   └── teacher/           # Teacher portal
│   │       ├── data/          # TeacherService, TeacherModels
│   │       └── presentation/  # TeacherDashboard, AttendanceMarking,
│   │                          # TeacherStudents, TeacherReports, TeacherSettings
│   ├── firebase_options.dart  # Firebase client configuration
│   └── main.dart              # Entrypoint, MultiProvider setup, MaterialApp
├── pubspec.yaml               # Project dependencies and asset definitions
└── README.md                  # This documentation
```

---

## Key Features

1. **Dual-Role Portal Workflow**:
   - Instant role detection upon login (`admin`, `teacher`, `admin_teacher`).
   - Seamless one-tap portal switching for combined `admin_teacher` roles without re-authenticating.

2. **Timetable Slot Attendance**:
   - Real-time slot selection: Class × Subject × Teacher × Period.
   - Batch attendance status marking (`Present`, `Late`, `Absent`, `Permission`) with reason notes.
   - Instant statistics cards and submission state tracking.

3. **Academic Score Formula**:
   - Monthly composite score blending: 70% teacher exam score + 30% attendance-derived score.
   - Normalized scoring across custom grade scales.

4. **Bilingual Localization (Khmer & English)**:
   - Full in-app translation for all screens, dialogs, buttons, and toasts.
   - Persistent language selection using `LocaleProvider`.

5. **Dynamic Theming (Light & Dark Mode)**:
   - Carefully tuned color palette (Slate-50 to Slate-900).
   - High-contrast toggle switches with distinct active/inactive thumb indicators, outlines, and iconography.

6. **Excel & CSV Bulk Import**:
   - Bulk upload student rosters directly with column mapping validation and preview.

---

## Prerequisites & Environment Setup

Ensure your local machine has the following tools installed:

- **Flutter SDK**: `^3.19.0` or higher ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: `^3.3.0` (included with Flutter)
- **Android Studio / VS Code** with Flutter and Dart extensions
- **Android SDK & Command-line Tools** (API 34/35 recommended)
- **Running Backend API**: Ensure the Voatmean backend is running on `http://localhost:5000` (or `http://10.0.2.2:5000` for Android Emulator).

Verify your environment by running:
```bash
flutter doctor
```

---

## How to Run the Application

> **Important**: Note that the Flutter mobile directory is named `mobile/`, NOT `app/`.

### 1. Navigate to the Mobile Directory
```bash
cd mobile
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Launch on an Emulator or Device
Start your target Android emulator or connect a physical device via USB, then run:
```bash
# Run in debug mode on connected device
flutter run

# Or explicitly target an emulator ID
flutter run -d emulator-5554
```

### 4. Standard Demo Accounts
For testing and evaluation, log in with the whitelisted database credentials:
- **Admin Account**: `admin@voatmean.edu.kh` / `admin123`
- **Teacher Account**: `teacher@voatmean.edu.kh` / `teacher123`
- **Google OAuth**: Use a whitelisted Google email (e.g. `k.sreyneath24@gmail.com` or `neangsrey137@gmail.com`).

---

## Building the APK

To generate a standalone APK for device installation and evaluation:

### Debug Build (Fast Testing)
```bash
cd mobile
flutter build apk --debug
```
*Output location:*
`mobile/build/app/outputs/flutter-apk/app-debug.apk`

### Release Build (Optimized & Shrunk)
```bash
cd mobile
flutter build apk --release
```
*Output location:*
`mobile/build/app/outputs/flutter-apk/app-release.apk`

### Install Directly to Connected Android Device via ADB:
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## Testing & Code Quality

The codebase enforces strict linting and code quality standards with zero analyzer issues:

```bash
cd mobile

# Static code analysis
flutter analyze

# Unit and widget tests
flutter test
```
