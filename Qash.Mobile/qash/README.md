# Qash — AI Powered Expense Tracker

Qash is a production-style, AI-powered expense tracking mobile application built with Flutter and Clean Architecture principles. Designed as a university graduation project, it follows startup-level architecture and engineering standards for maintainability, scalability, and security.

---

## Table of Contents

- Project Overview
- Tech Stack
- Architecture
- Project Structure
- Folder Explanation
- State Management
- Networking
- Authentication
- Environment & Storage
- Model Generation
- Routing & Theme
- Security & Scalability
- Current Progress
- Upcoming Features

---

## Project Overview

Qash helps users:

- Track expenses and income
- Manage multiple wallets
- Analyze spending habits
- Create budgets and savings goals
- Receive AI-powered financial insights
- Export financial reports
- Manage recurring transactions

This application is built as a university graduation-level project but follows production-grade engineering practices.

---

## Tech Stack

### Frontend

- Flutter
- Riverpod
- Dio
- go_router
- Hive
- Freezed
- json_serializable

### Backend

- ASP.NET Core Web API (.NET 8)
- PostgreSQL
- Railway (deployment)

---

## Architecture

The project follows:

- Clean Architecture
- Feature-First Structure
- SOLID Principles
- Scalable Modular Design

### Why Clean Architecture?

- Separation of concerns
- Scalability
- Easier testing
- Better maintainability
- Independent business logic

This separation is especially important in fintech applications where correctness and auditability matter.

---

## Project Structure

```text
lib/
│
├── core/
├── features/
├── shared/
├── config/
└── main.dart
```

---

## Folder Explanation

### core/

Contains reusable app-wide infrastructure and utilities.

```text
core/
├── constants/
├── errors/
├── network/
├── services/
├── storage/
├── theme/
├── utils/
└── widgets/
```

#### constants/

Stores centralized constants such as API URLs, timeout durations, storage keys, and app-wide static values.

#### errors/

Handles exceptions, failures, and API error mapping for consistent error presentation.

#### network/

Contains networking infrastructure: Dio client, interceptors, request configuration, and authentication headers.

#### services/

Reusable services (JWT handling, analytics, notifications).

#### storage/

Local and secure storage (Hive, flutter_secure_storage) for caching and token storage.

#### theme/

Centralized design system: colors, typography, and dark mode support.

#### utils/

Helper utilities: validators, extensions, formatters.

#### widgets/

Globally reusable widgets (buttons, inputs, loaders).

---

## features/

Contains all application features. Each feature follows a modular clean architecture layout:

```text
features/
└── auth/
	├── data/
	├── domain/
	├── presentation/
	└── providers/
```

### Feature Layers

#### data/

Responsible for remote/local data access, DTO mapping, and repository implementations.

#### domain/

Pure business logic: entities, use-cases, and abstract repositories (no Flutter or platform dependencies).

#### presentation/

UI layer: pages, widgets, controllers — visual components only.

#### providers/

Riverpod providers for dependency injection and state management.

---

## State Management

Using `flutter_riverpod` for type-safety, testability, and scalable async state handling.

---

## Networking

Using `Dio` for HTTP client features like interceptors, cancellation, and global configuration.

Networking flow:

```text
UI
→ Provider
→ UseCase
→ Repository
→ RemoteDataSource
→ API
```

UI never calls Dio directly; networking is abstracted behind repositories.

---

## Authentication System

Designed with:

- JWT access tokens
- Refresh tokens
- Secure token storage (`flutter_secure_storage`)
- Auto-login and route guards

Security note: Never store sensitive tokens in plain `SharedPreferences`.

---

## Environment Configuration

Using `flutter_dotenv` for environment-specific values (API URLs, keys). Keeps secrets out of source code and supports dev/staging/prod setups.

---

## Local Storage

Using `Hive` for lightweight, fast local storage and offline caching.

---

## Model Generation

Using `freezed` and `json_serializable` for immutable models, `copyWith`, and JSON serialization.

---

## Routing

Using `go_router` for nested navigation, deep linking, and auth redirects.

---

## Theme System

Supports dark mode, centralized colors, and reusable typography for consistent fintech UI.

---

## Security Practices

- Secure token storage
- Refresh token rotation
- Centralized interceptors
- No hardcoded secrets

---

## Scalability Goals

Designed to support AI features, offline mode, push notifications, multi-wallets, analytics dashboards, and real-time updates without major refactors.

---

## Current Progress

### Completed

- Flutter project setup
- Clean architecture scaffold
- Riverpod setup
- Dio networking infra
- Environment configuration
- Secure storage setup
- Theme system
- Router setup

---

## Upcoming Features

- Authentication system
- Wallet management
- Transactions
- Categories
- Analytics
- Budgets
- Saving goals
- AI insights
- Notifications
- Export reports
- Profile management

---

## Backend

Backend API stack:

- ASP.NET Core Web API (.NET 8)
- PostgreSQL
- Railway deployment

Frontend consumes production-like APIs.

---

## Future Improvements

- AI spending insights
- OCR receipt scanning
- Financial predictions
- Real-time notifications
- Multi-currency support
- Offline-first architecture

---

## Author

Developed as a professional fintech mobile application project following modern Flutter and backend engineering practices.

---

### Quick Commands

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Analyze code:

```bash
flutter analyze
```

---

If you'd like, I can run `flutter analyze` next or create a concise contributing guide.
