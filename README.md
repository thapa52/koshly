# Koshly

> Derived from the Nepali word *Kosh* (कोष), meaning Treasury.

A production-level personal finance dashboard built with Flutter & Clean Architecture. Track expenses, income, savings goals, and generate reports — fully offline.

---

## Screenshots

*Coming soon*

---

## Features

- **Dashboard** — Beautiful financial overview with spending charts
- **Transactions** — Track income and expenses with categories
- **Savings Goals** — Set goals, track progress, add contributions
- **Reports** — Monthly summaries with CSV and PDF export
- **Bill Reminders** — Local notifications for upcoming bills
- **Dark/Light Theme** — Full theme support with persistence
- **Fully Offline** — No internet connection required ever

---

## Tech Stack

| Category | Technology |
| :--- | :--- |
| **Framework** | Flutter 3.29.3 |
| **Language** | Dart 3.7.2 |
| **State Management** | Riverpod 2.x with Annotations |
| **Navigation** | GoRouter |
| **Local Database** | Hive |
| **Charts** | FL Chart |
| **Code Generation** | Hive Generator, Riverpod Generator |
| **Notifications** | Flutter Local Notifications |
| **Export** | PDF, CSV |
| **Preferences** | Shared Preferences |
| **Testing** | flutter_test, mocktail |

---

## Architecture

This project follows **Clean Architecture** principles with a feature-first folder structure.

~~~
lib/
├── core/                          # Shared across all features
│   ├── constants/                 # App-wide constants
│   ├── error/                     # Failure classes
│   ├── navigation/                # GoRouter configuration
│   ├── providers/                 # Global providers (theme)
│   ├── services/                  # Cross-cutting services (notifications)
│   ├── theme/                     # Light & dark theme
│   ├── utils/                     # Date and currency formatters
│   └── widgets/                   # Reusable widgets (BalanceCard)
│
├── features/
│   ├── dashboard/                 # Financial overview & charts
│   │   └── presentation/
│   │       ├── providers/         # Dashboard computed providers
│   │       ├── screens/           # Dashboard screen
│   │       └── widgets/           # Chart widgets
│   │
│   ├── transactions/              # Income & expense tracking
│   │   ├── data/                  # Hive models, repository implementation
│   │   ├── domain/                # Entities, use cases, repository interface
│   │   └── presentation/          # Providers, screens, widgets
│   │
│   ├── savings/                   # Savings goals tracking
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── reports/                   # Monthly reports & export
│   │   ├── data/                  # CSV and PDF export services
│   │   ├── domain/                # Export service interface
│   │   └── presentation/          # Report screen and providers
│   │
│   └── settings/                  # App preferences
│       └── presentation/
│           └── screens/           # Settings screen
│
└── main.dart
~~~

---

## Getting Started

### Prerequisites

- Flutter 3.29.3
- Dart 3.7.2
- Android Studio / VS Code

### Installation

1. **Clone the repository**

~~~bash
git clone git@github.com:thapa52/koshly.git
cd koshly
~~~

2. **Install dependencies**

~~~bash
flutter pub get
~~~

3. **Generate required files**

~~~bash
dart run build_runner build --delete-conflicting-outputs
~~~

4. **Run the app**

~~~bash
flutter run
~~~

---

## Code Generation

This project uses code generation for:
- Hive adapters (local database)
- Riverpod providers
- JSON serialization

Generated files (`*.g.dart`, `*.freezed.dart`) are **not committed** to Git.

After cloning, always run:

~~~bash
dart run build_runner build --delete-conflicting-outputs
~~~

During active development, use watch mode:

~~~bash
dart run build_runner watch --delete-conflicting-outputs
~~~

---

## Testing

Run the full test suite:

~~~bash
flutter test
~~~

Run with detailed output:

~~~bash
flutter test --reporter expanded
~~~

### Test Coverage

| Feature | Tests |
| :--- | :--- |
| Transaction use cases | 56 tests |
| Savings use cases | 51 tests |
| **Total** | **107 tests** |

All tests use fake repository implementations — no real database or network calls.

---

## Project Setup Progress

- [x] Project initialization
- [x] Clean Architecture folder structure
- [x] Dependencies configured
- [x] Android build configuration
- [x] Core layer (Theme, Constants, Error Handling)
- [x] Transaction domain layer (Entities, Repository, Use Cases)
- [x] Transaction data layer (Hive models, Repository implementation)
- [x] Transaction presentation layer (Providers, Screens, Widgets)
- [x] GoRouter navigation
- [x] Dashboard with FL Chart (Pie chart, Bar chart, Recent transactions)
- [x] Unit Tests (107 tests passing)
- [x] Savings feature (Goals, progress tracking, contributions)
- [x] Reports & Export (Monthly reports, CSV and PDF export)
- [x] Theme toggle & Settings (Light/Dark/System with persistence)
- [x] Notifications (Bill reminders with local notifications)
- [x] Final polish (Reusable widgets, TODO cleanup)

---

## Developer

**Pradeep Thapa**
Flutter Developer
[GitHub](https://github.com/thapa52)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.