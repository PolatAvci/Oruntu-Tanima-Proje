# Signature Verification App

A modern, elegant Flutter application for signature authenticity verification. Built with **Clean Architecture**, featuring a wizard-style multi-step flow, fluid animations, and a polished Material 3 design system.

---

## Features

- **Wizard-Style Flow** — Three-step sequential UX: Reference Signature → Test Signature → Result
- **Image Capture** — Pick images from Camera or Gallery with a modern dashed-border placeholder
- **Real-time Validation** — Action buttons disable/enable dynamically based on selection state
- **Beautiful Results** — Dynamic result cards with gradient backgrounds, semi-circular confidence gauges, and contextual icon animations
- **Fluid Animations** — Staggered entrance animations via `flutter_animate` for every screen element
- **Clean Architecture** — Domain-driven layered architecture with Use Cases, Repository pattern, and dependency injection
- **Performance-First** — `context.select` for granular rebuild isolation; no unnecessary widget repaints

---

## Architecture

This project follows **Clean Architecture** principles with a feature-first folder structure:

```
lib/
├── core/
│   ├── animations/          # Reusable animation presets
│   ├── constants/             # App-wide constants
│   ├── errors/                # Failures & Exceptions
│   ├── theme/                 # Colors, Typography, ThemeData
│   └── usecases/              # Base UseCase contract
├── features/signature_verification/
│   ├── domain/
│   │   ├── entities/          # VerificationResultEntity
│   │   ├── repositories/      # Abstract repository contracts
│   │   └── usecases/          # PickReference, PickTest, Verify
│   ├── data/
│   │   ├── datasources/       # Local (image_picker) & Remote (API)
│   │   ├── models/            # DTOs with JSON serialization
│   │   └── repositories/      # Concrete repository implementations
│   └── presentation/
│       ├── providers/         # SignatureVerificationProvider (ChangeNotifier)
│       ├── pages/             # Step 1, Step 2, Result
│       └── widgets/           # Reusable UI components
└── main.dart                  # Entry point + DI initialization
```

### Layers

| Layer | Responsibility |
|-------|----------------|
| **Presentation** | UI, state management (Provider), user interactions |
| **Domain** | Business logic, entities, use cases, repository contracts |
| **Data** | Concrete data sources, models, repository implementations |

### Error Handling

All use cases return an `Either<Failure, Success>` (via `dartz`), cleanly separating expected errors from exceptions. Failures are mapped to user-friendly messages in the presentation layer.

---

## Tech Stack

| Category | Package |
|----------|---------|
| State Management | `provider` |
| Dependency Injection | `get_it` |
| Functional Programming | `dartz` |
| Image Picker | `image_picker` |
| Animations | `flutter_animate` |
| Typography | `google_fonts` |
| Icons | `font_awesome_flutter` |
| Utilities | `equatable`, `path_provider` |

---

## User Flow

```
┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│   Step 1: Reference  │ ──▶ │   Step 2: Test      │ ──▶ │   Step 3: Result    │
│   Signature          │     │   Signature         │     │                     │
│                      │     │                     │     │                     │
│ • Select/Capture     │     │ • Select/Capture    │     │ • Loading Spinner   │
│   original image     │     │   suspect image     │     │ • Result Card       │
│ • "Next Step" CTA    │     │ • "Verify" CTA      │     │   (Genuine/Forged)  │
│   (disabled until    │     │   (disabled until   │     │ • Confidence Gauge  │
│    image selected)   │     │    image selected)  │     │ • "Start Over" CTA  │
└─────────────────────┘     └─────────────────────┘     └─────────────────────┘
```

### Navigation Strategy

- Step 1 pushes Step 2 via `Navigator.push`
- Step 2 pushes Step 3 via `Navigator.push`
- "Start Over" on Step 3 uses `pushAndRemoveUntil` to reset the entire navigation stack and return to Step 1
- The Provider is injected at the `main.dart` root, so state persists across the wizard

---

## Design System

The app uses a custom theme built on an **indigo/violet** primary palette with **slate** neutrals.

### Color Tokens

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#4F46E5` | Buttons, active indicators |
| Primary Gradient | `indigo → violet` | Header badges, result backgrounds |
| Success | `#10B981` | Genuine results |
| Error | `#EF4444` | Forged results / errors |
| Surface | `#FFFFFF` | Cards |
| Background | `#F8FAFC` | Scaffold background |

### Typography

All text uses **Inter** via `google_fonts` with a tight hierarchy:

- **Headline Large** — 28px, weight 700, letter-spacing -0.5 (screen titles)
- **Title Large** — 18px, weight 600 (card labels)
- **Body Large** — 16px, weight 400 (descriptions)
- **Label Large** — 14px, weight 500 (button text)

### Animations

Every screen element animates in with a staggered sequence using `flutter_animate`:

1. **Icon Badge** — scale from `0` with `easeOutBack` (600ms)
2. **Headline** — fade + slideY from `0.2` (400ms, 100ms delay)
3. **Subtitle** — fade + slideY from `0.15` (400ms, 200ms delay)
4. **Image Area** — fade + slideY from `0.1` (500ms, 200ms delay)
5. **Buttons** — fade + slideY from `0.1` (400ms, 300ms delay)
6. **CTA** — fade + slideY from `0.1` (400ms, 400ms delay)

---

## Setup & Installation

### Prerequisites

- Flutter SDK `>= 3.11.0`
- Dart `>= 3.0.0`
- Android Studio / Xcode (for emulators)

### Steps

```bash
# 1. Clone the repository
git clone <repository-url>
cd frontend

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Platform-Specific Notes

**Android:**
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**iOS:**
Add the following keys to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture signatures.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select signatures.</string>
```

---

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

The project includes widget tests that verify:
- The wizard Step 1 renders correctly
- All action buttons (Camera, Gallery, Next Step) are present
- Provider injection works at the root level

---

## Project Structure Details

### Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point; initializes DI and wraps app with Provider |
| `lib/app.dart` | Root `MaterialApp` with custom theme and first screen |
| `lib/injection_container.dart` | `get_it` service locator configuration |
| `lib/core/theme/app_theme.dart` | `ThemeData` factory with component themes |
| `lib/core/theme/app_colors.dart` | Semantic color palette tokens |
| `lib/core/theme/app_text_styles.dart` | Centralized `TextStyle` definitions |

### Wizard Pages

| Page | File | Key Widgets |
|------|------|-------------|
| Step 1 | `signature_capture_page.dart` | `WizardStepIndicator`, `SignatureImageArea`, `GradientButton` |
| Step 2 | `test_signature_page.dart` | Same shared widgets, calls `verifySignatures()` |
| Step 3 | `signature_verification_result_page.dart` | `VerificationResultCard`, loading state, error banner |

### Reusable Widgets

| Widget | File | Description |
|--------|------|-------------|
| `GradientButton` | `gradient_button.dart` | Full-width gradient CTA with loading state and press scaling |
| `SignatureImageArea` | `signature_image_area.dart` | Shared dashed-border placeholder / animated image preview |
| `WizardStepIndicator` | `wizard_step_indicator.dart` | Numbered step circles with connector lines and completed states |
| `VerificationResultCard` | `verification_result_card.dart` | Dynamic gradient card with gauge, confidence, and contextual icon |
| `ErrorBanner` | `error_banner.dart` | Animated slide-in error banner with dismiss action |

---

## Future Enhancements

- [ ] Connect to a real backend API for signature comparison (currently simulated)
- [ ] Add signature cropping / rotation tools before verification
- [ ] Persist verification history in local storage
- [ ] Dark mode theme support
- [ ] Biometric authentication before accessing sensitive results
- [ ] Export verification reports as PDF

---

## License

This project is for educational and demonstration purposes.

---

## Acknowledgements

- [Flutter](https://flutter.dev) — UI toolkit
- [Provider](https://pub.dev/packages/provider) — State management
- [flutter_animate](https://pub.dev/packages/flutter_animate) — Declarative animations
- [Google Fonts](https://fonts.google.com) — Inter typeface
