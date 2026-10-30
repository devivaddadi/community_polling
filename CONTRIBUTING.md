# Contributing to Community Polling App

Thank you for taking the time to contribute! 🎉

This document provides guidelines and recommendations for contributing to the Community Polling App (CPA) project. Following these guidelines helps maintain clean, reliable, and high-quality code.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Style Guidelines](#style-guidelines)
  - [Dart & Flutter Conventions](#dart--flutter-conventions)
  - [Git Commit Guidelines](#git-commit-guidelines)
- [Testing](#testing)

---

## Code of Conduct

This project and everyone participating in it is governed by the [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

---

## How Can I Contribute?

### Reporting Bugs

Before submitting a bug report, please check existing issues to avoid duplicates.

When submitting a bug report:
1. Use the **Bug Report** issue template.
2. Provide a clear and descriptive summary.
3. Include steps to reproduce the issue.
4. Specify your Flutter environment (`flutter doctor -v`), OS, and device/emulator details.
5. Include logs and screenshots if relevant.

### Suggesting Enhancements

Feature requests and improvements are welcome!
1. Use the **Feature Request** issue template.
2. Clearly explain the motivation and use case for the proposed feature.
3. Describe expected behavior and possible alternatives considered.

### Pull Requests

1. **Fork** the repository and create your branch from `main`:
   ```bash
   git checkout -b feature/amazing-feature
   # or
   git checkout -b bugfix/issue-description
   ```
2. Ensure dependencies and tests pass before committing.
3. Follow the commit message conventions.
4. Push your branch and open a Pull Request against the `main` branch.
5. Provide a clear description of what changed and reference any related issues (e.g., `Closes #12`).

---

## Development Setup

1. **Prerequisites**:
   - Flutter SDK (^3.12 or compatible)
   - Dart SDK
   - Android Studio / VS Code / Xcode
   - Git

2. **Clone & Install**:
   ```bash
   git clone https://github.com/devivaddadi/community_polling.git
   cd community_polling
   flutter pub get
   ```

3. **Run App**:
   ```bash
   flutter run
   ```

---

## Style Guidelines

### Dart & Flutter Conventions

- Follow the official [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines.
- Adhere to the lint rules defined in `analysis_options.yaml`.
- Format code using `dart format .` before committing.
- Run static analysis:
  ```bash
  flutter analyze
  ```
  Ensure there are no errors or unhandled warnings.

### Git Commit Guidelines

Use conventional commit messages:
- `feat: add community decision filter`
- `fix: resolve vote count synchronization issue`
- `docs: update setup and API documentation`
- `style: format widgets according to linter`
- `refactor: optimize realtime listener subscriptions`
- `test: add unit tests for poll provider`

---

## Testing

Run unit and widget tests before submitting PRs:
```bash
flutter test
```

Make sure all tests pass and consider adding new tests for new features or bug fixes.
