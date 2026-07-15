# ALU InternLink

A Flutter + Firebase marketplace connecting ALU students seeking internship experience
with student-led startups and early-stage ventures inside the ALU ecosystem. Startups
post opportunities (gated behind ALU verification), students discover and apply, and
both sides track the application pipeline in real time.

Full architecture, schema, and design rationale: [`docs/TECHNICAL_REPORT.md`](docs/TECHNICAL_REPORT.md).
Demo recording walkthrough: [`docs/DEMO_SCRIPT.md`](docs/DEMO_SCRIPT.md).

## Stack

- **Flutter** (Dart 3.11, Flutter 3.41)
- **State management:** Riverpod (`flutter_riverpod`) — see rationale in the technical report, §3.1
- **Backend:** Firebase Auth (email/password), Cloud Firestore (real-time), Cloud Storage, Cloud Messaging

## Core features

- Role-based authentication & onboarding (student / startup)
- Startup verification gate — only ALU-recognized startups can post opportunities
  (enforced server-side via `firestore.rules`, not just in the UI)
- Opportunity posting, editing, and deletion
- Discover feed with search, category, and mode filters
- Application submission with a note, tracked in real time
- Startup applicant pipeline with status transitions
  (Pending → Shortlisted → Interview → Accepted/Closed)
- Bookmarking

## Project structure

```
lib/
  models/        Immutable data models (Opportunity, ApplicationRecord, AuthState, enums)
  providers/      Riverpod StateNotifier controllers (AuthController, MarketplaceController)
  screens/        UI, organized by feature (auth, onboarding, home, discover, applications, profile, opportunity)
  widgets/        Shared UI components
firestore.rules   Firestore security rules (role- and ownership-based access)
docs/             Technical report and demo script
```

## Getting started

### Prerequisites
- Flutter SDK (3.41+) — `flutter doctor` should show no blocking issues
- A configured Firebase project (this repo ships with `lib/firebase_options.dart` for the
  `aluinternlink` project; run `flutterfire configure` to point at your own project)
- An Android emulator or a physical Android device with USB debugging enabled
  (this app must run on a device/emulator — browser builds are not graded)

### Run it

```bash
flutter pub get
flutter devices          # confirm your emulator/device is detected
flutter run -d <device-id>
```

### Deploy Firestore rules

```bash
firebase deploy --only firestore:rules
```

### Verifying a startup account (simulates ALU admin approval)

New startup accounts start unverified and cannot post. To approve one for testing/demo:
in the Firebase console, open **Firestore → `users/{uid}`** for that account and set
`verifiedStartup` to `true`.

## Static analysis

```bash
flutter analyze
```
