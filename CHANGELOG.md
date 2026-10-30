# Changelog

All notable changes to the Community Polling App (CPA) project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-10-30

### Added
- **Core Architecture & Navigation**:
  - Implemented `MainShell` with bottom navigation for easy access to Dashboard, Active Polls, Decisions, and Profile.
  - Multi-community selection and switching support with `CommunityProvider`.
- **Authentication**:
  - Email/Password authentication flow with login and registration screens.
  - Mock authentication mode alongside Firebase backend integration.
  - Persistent user session handling using `shared_preferences`.
- **Polls & Voting Engine**:
  - Dynamic poll creation with custom title, description, categories, tags, deadlines, and multi-option configurations.
  - Active polls discovery and category filtering (Infrastructure, Environment, Events, Safety & Security, Finance, Recreation, etc.).
  - Real-time vote casting with immediate percentage calculation and option progress bars.
  - Poll details view with voting status, author info, and deadline indicators.
  - Poll results visualization featuring custom interactive Donut and Line charts.
- **Discussion System**:
  - Comment threads attached to each poll for pre-vote community debates.
  - Timestamp formatting and author avatar integration.
- **Admin & Decision Tracking**:
  - Admin dashboard with high-level community metric statistics (active polls, total votes, participation rate).
  - Decision tracking workflow: converts closed poll results into actionable community decisions with statuses (Proposed, In Progress, Implemented).
  - Community member management screen with role toggling (Admin / Member).
  - Administrative poll deletion with confirmation dialog.
- **Notifications**:
  - Notifications screen showing vote alerts, poll closure updates, and decision statuses.
- **Real-time Database**:
  - Realtime Database service integration using Firebase Realtime Database.
  - Automatic fallback to mock data service for offline demo and development.
