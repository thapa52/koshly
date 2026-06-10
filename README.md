# Koshly

> Derived from the Nepali word *Kosh* (कोष), meaning Treasury.

A production-level personal finance dashboard built with Flutter & Clean Architecture. Track expenses, income, savings goals, and generate reports — fully offline.

---

## Screenshots

*Coming soon*

---

## Features

- **Dashboard** — Beautiful overview of your financial health
- **Transactions** — Track income and expenses with categories
- **Savings Goals** — Set and track progress toward financial goals
- **Reports** — Monthly/weekly charts and analytics
- **Bill Reminders** — Local notifications for upcoming bills
- **Export** — Generate PDF and CSV reports
- **Dark/Light Theme** — Full theme support
- **Fully Offline** — No internet connection required

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
| **Code Generation** | Freezed, Riverpod Generator |
| **Notifications** | Flutter Local Notifications |
| **Export** | PDF, CSV |
| **Preferences** | Shared Preferences |

---

## Architecture

This project follows **Clean Architecture** principles with a feature-first folder structure.

~~~
lib/
├── core/                     # Shared across all features
│   ├── constants/            # App-wide constants
│   ├── error/                # Error handling
│   ├── theme/                # Light & dark theme
│   ├── utils/                # Utility functions
│   └── widgets/              # Reusable widgets
│
├── features/
│   ├── dashboard/            # Financial overview & charts
│   │   ├── data/             # Hive models, repositories
│   │   ├── domain/           # Entities, use cases
│   │   └── presentation/     # Screens, widgets, providers
│   │
│   ├── transactions/         # Income & expense tracking
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── savings/              # Savings goals tracking
│       ├── data/
│       ├── domain/
│       └── presentation/
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

3. **Run the app**

~~~bash
flutter run
~~~

---

## Project Setup Progress

- [x] Project initialization
- [x] Clean Architecture folder structure
- [x] Dependencies configured
- [x] Android build configuration
- [ ] Core layer (Theme, Constants, Error Handling)
- [ ] Transaction feature
- [ ] Savings feature
- [ ] Dashboard & Charts
- [ ] Reports & Export
- [ ] Notifications
- [ ] Unit Tests

---

## Developer

**Pradeep Thapa**  
Flutter Developer  
[GitHub](https://github.com/thapa52)

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.