# Qash — Personal Finance Tracker

A full-stack personal finance application built as a university project. Qash lets users track income, expenses, and transfers across multiple wallets in multiple currencies, set monthly budgets, manage savings goals, and view spending analytics.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Repository Structure](#3-repository-structure)
4. [Backend — Qash.API](#4-backend--qashapi)
   - [Architecture](#41-architecture)
   - [API Endpoints](#42-api-endpoints)
   - [Domain Entities & Relationships](#43-domain-entities--relationships)
   - [Authentication & Security](#44-authentication--security)
   - [Infrastructure Services](#45-infrastructure-services)
   - [Configuration](#46-configuration)
5. [Frontend — Qash.Mobile](#5-frontend--qashmobile)
   - [Architecture](#51-architecture)
   - [Screens & Routes](#52-screens--routes)
   - [Features](#53-features)
   - [Core Utilities](#54-core-utilities)
   - [State Management](#55-state-management)
6. [Database](#6-database)
7. [Getting Started](#7-getting-started)
   - [Prerequisites](#71-prerequisites)
   - [Backend Setup](#72-backend-setup)
   - [Mobile Setup](#73-mobile-setup)
8. [API ↔ Mobile Coverage](#8-api--mobile-coverage)
9. [Validation Rules](#9-validation-rules)
10. [Known Limitations & Future Work](#10-known-limitations--future-work)

---

## 1. Project Overview

**Qash** is a personal finance tracker with:

- Multi-currency wallet management (USD, EGP, EUR, GBP, JPY)
- Income, expense, and transfer transactions
- Monthly category budgets with real-time status
- Savings goals with contribution tracking
- Spending analytics and reports
- Background processing for recurring transactions
- JWT-based authentication with refresh token rotation

---

## 2. Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.x, Dart |
| State management | Flutter Riverpod |
| Navigation | GoRouter |
| HTTP client | Dio |
| Secure storage | flutter_secure_storage |
| Backend | ASP.NET Core 8 Web API |
| ORM | Entity Framework Core 8 |
| Database | PostgreSQL (Npgsql) |
| Messaging | MediatR (CQRS pattern) |
| Validation | FluentValidation |
| Object mapping | AutoMapper |
| Authentication | JWT Bearer + Refresh Tokens |
| PDF export | QuestPDF |
| CSV export | CsvHelper |
| Background jobs | .NET IHostedService |

---

## 3. Repository Structure

```
Qash/
├── Qash.sln                        # Solution file
├── README.md
│
├── Qash.API/                       # ASP.NET Core 8 Web API
│   ├── Controllers/                # 13 API controllers
│   ├── Features/                   # CQRS feature modules
│   │   ├── Auth/
│   │   ├── Profile/
│   │   ├── Transactions/
│   │   ├── Wallet/
│   │   ├── Budgets/
│   │   ├── Dashboard/
│   │   ├── Reports/
│   │   ├── Categories/
│   │   ├── SavingGoals/
│   │   ├── RecurringTransactions/
│   │   ├── Insights/
│   │   └── Export/
│   ├── Domain/
│   │   ├── Entities/               # Database entities (all extend BaseEntity)
│   │   ├── Enums/                  # CategoryType, RecurringFrequency, ExportFormat
│   │   └── Common/                 # BaseEntity
│   ├── Infrastructure/
│   │   ├── Authentication/         # JWT token service
│   │   ├── Background/             # Recurring transaction job
│   │   ├── Data/                   # ApplicationDbContext + migrations
│   │   ├── Mapping/                # AutoMapper profile
│   │   ├── Scheduling/             # Next-run calculator
│   │   └── Services/               # Password hasher, exchange rates, currency conversion
│   ├── Common/
│   │   └── Responses/              # ApiResponse<T> envelope
│   ├── Migrations/
│   ├── Program.cs
│   └── appsettings.json
│
└── Qash.Mobile/
    └── qash/                       # Flutter project root
        ├── lib/
        │   ├── main.dart
        │   ├── config/             # Router, providers
        │   ├── core/               # Shared infrastructure
        │   │   ├── errors/
        │   │   ├── input/
        │   │   ├── network/
        │   │   ├── providers/
        │   │   ├── storage/
        │   │   ├── theme/
        │   │   ├── utils/
        │   │   ├── validation/
        │   │   └── widgets/
        │   └── features/           # Feature modules (clean architecture)
        │       ├── analytics/
        │       ├── auth/
        │       ├── budgets/
        │       ├── categories/
        │       ├── dashboard/
        │       ├── goals/
        │       ├── onboarding/
        │       ├── profile/
        │       ├── splash/
        │       ├── transactions/
        │       └── wallets/
        ├── assets/
        │   └── icons/
        ├── pubspec.yaml
        └── .env                    # BASE_URL (not committed)
```

---

## 4. Backend — Qash.API

### 4.1 Architecture

The backend follows **CQRS** (Command Query Responsibility Segregation) via **MediatR**. Every feature is self-contained:

```
Features/<Name>/
  Commands/        # Write models (IRequest<ApiResponse<T>>)
  Queries/         # Read models
  Handlers/        # Business logic
  DTOs/            # Response shapes
  Validators/      # FluentValidation rules
```

**API envelope — `ApiResponse<T>`**

Every endpoint returns a consistent JSON shape:

```json
{
  "success": true,
  "message": "...",
  "data": { ... },
  "errors": []
}
```

**Soft delete** — all entities inherit `BaseEntity` and are never hard-deleted. A global EF query filter excludes `IsDeleted = true` rows automatically.

---

### 4.2 API Endpoints

Base URL: `http://<host>:<port>/api`  
Default port: **8080**

All endpoints require `Authorization: Bearer <access_token>` unless marked **Public**.

---

#### Auth — `/api/auth`

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/register` | Public | Create a new user account |
| POST | `/verify-phone` | Public | Verify phone number with OTP code |
| POST | `/login` | Public | Authenticate; returns access + refresh tokens |
| POST | `/refresh-token` | Public | Exchange a refresh token for new token pair |
| POST | `/logout` | Public | Revoke a refresh token |
| POST | `/forgot-password/request-code` | Public | Send OTP code to phone for password reset |
| POST | `/forgot-password/reset` | Public | Reset password using phone + OTP + new password |
| POST | `/change-password` | **Required** | Change password (user inferred from JWT) |

---

#### Profile — `/api/profile`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Get authenticated user's profile |
| PUT | `/` | Update profile (first name, last name, email, preferred currency) |
| DELETE | `/` | Delete account (requires `password` in request body) |

> **Note:** Phone number cannot be changed after account creation. The backend rejects any update where the submitted phone number differs from the stored value.

---

#### Transactions — `/api/transactions`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/` | Create a transaction (income / expense / transfer) |
| GET | `/` | List transactions; optionally filter by `?walletId=<id>` |
| GET | `/{id}` | Get a single transaction by ID |
| PUT | `/{id}` | Update a transaction |
| DELETE | `/{id}` | Delete a transaction |

**Transfer transactions** create two linked records sharing a `TransferGroupId`. Multi-currency transfers store both `Amount` (source) and `ToAmount` (destination), plus the exchange rate used.

---

#### Wallets — `/api/wallets`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/` | Create a wallet |
| GET | `/` | List all wallets for the user |
| GET | `/{id}` | Get a single wallet |
| PUT | `/{id}` | Update wallet (name, currency, balance) |
| DELETE | `/{id}` | Delete a wallet |
| GET | `/{id}/balance` | Get wallet current balance |

---

#### Budgets — `/api/budgets`

| Method | Endpoint | Query | Description |
|--------|----------|-------|-------------|
| GET | `/status` | `year`, `month` | Budget status per category for a given month |
| POST | `/` | — | Create a monthly budget for a category |
| PUT | `/{id}` | — | Update a budget |
| DELETE | `/{id}` | — | Delete a budget |

---

#### Dashboard — `/api/dashboard`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Returns total balance, monthly income/expense, recent transactions, top spending categories |

All amounts are converted to the user's `PreferredCurrency`.

---

#### Reports — `/api/reports`

| Method | Endpoint | Query Parameters | Description |
|--------|----------|-----------------|-------------|
| GET | `/monthly-summary` | `year`, `month` | Total income and expense for a month |
| GET | `/category-breakdown` | `year`, `month` | Spending grouped by category |
| GET | `/income-vs-expense` | `year` | Monthly income vs expense for the full year |
| GET | `/spending-trend` | `days` | Daily spending over the last N days |
| GET | `/date-range-summary` | `fromUtc`, `toUtc` | Summary for an arbitrary date range |

---

#### Categories — `/api/categories`

| Method | Endpoint | Query | Description |
|--------|----------|-------|-------------|
| GET | `/` | `?type=Income\|Expense\|Transfer` | List categories (optionally filtered by type) |
| POST | `/` | — | Create a custom category |
| PUT | `/{id}` | — | Update a category |
| DELETE | `/{id}` | — | Delete a category |

---

#### Saving Goals — `/api/saving-goals`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | List all savings goals |
| GET | `/{id}` | Get a single goal |
| POST | `/` | Create a new goal |
| PUT | `/{id}` | Update a goal |
| POST | `/{id}/contribute` | Add funds to a goal |
| DELETE | `/{id}` | Delete a goal |

---

#### Recurring Transactions — `/api/recurring-transactions`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | List recurring rules |
| GET | `/{id}` | Get a single rule |
| POST | `/` | Create a recurring rule |
| PUT | `/{id}` | Update a rule |
| DELETE | `/{id}` | Delete a rule |

A background hosted service runs every hour and creates actual transactions for overdue rules.

---

#### Exchange Rates — `/api/exchange-rates`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Returns the configured FX rates dictionary (USD base) |

---

#### Insights — `/api/insights`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Rule-based spending tips (high category share, overspending, etc.) based on last 30 days |

---

#### Export — `/api/export`

| Method | Endpoint | Query | Description |
|--------|----------|-------|-------------|
| GET | `/transactions` | `fromUtc`, `toUtc`, `format` (Csv \| Pdf) | Download transaction export file |

---

### 4.3 Domain Entities & Relationships

```
ApplicationUser
├── Id (GUID)
├── FirstName, LastName
├── Email (unique, case-insensitive)
├── PhoneNumber (unique)
├── IsPhoneNumberVerified
├── PasswordHash
├── PreferredCurrency (default: USD)
├── RefreshToken[]        → cascade delete
├── Wallet[]              → cascade delete
├── Transaction[]         → cascade delete
└── Category[]            → cascade delete

Wallet
├── Id, Name, Currency, Balance
└── Transaction[] (as source wallet)

Transaction
├── Id, TransactionType (Income | Expense | Transfer)
├── Amount, SourceCurrency
├── ToAmount?, DestinationCurrency?   (transfers only)
├── AmountInBaseCurrency, ExchangeRateUsed?
├── Description, TransactionDate
├── TransferGroupId?                  (pairs source + destination legs)
├── LinkedTransactionId?              (counterpart transaction reference)
├── ApplicationUser → FK (cascade)
├── Wallet          → source wallet FK (cascade)
├── ToWallet?       → destination wallet FK (restrict)
└── Category        → FK (restrict)

Category
├── Id, Name, Type (Income | Expense | Transfer), Icon?, Color?
└── Transactions[]

Budget
├── Id, Amount, Currency, Year, Month
├── ApplicationUser → FK
└── Category        → FK
    (unique constraint: user + category + year + month)

SavingGoal
├── Id, Name, TargetAmount, CurrentAmount, Currency, Deadline?
└── ApplicationUser → FK

RecurringTransaction
├── Id, Frequency, NextRunAt, IsActive
├── Amount, Currency, Description
├── ApplicationUser, Wallet, Category → FK

RefreshToken
├── Id, Token, ExpiresAt, IsRevoked, RevokedAt
└── ApplicationUser → FK (cascade)
```

---

### 4.4 Authentication & Security

**Flow:**

```
Register → Verify Phone (OTP) → Login → Access Token (15 min) + Refresh Token (7 days)
                                      ↓
                          Auto-refresh via interceptor
                          (proactive on near-expiry, reactive on 401)
```

**JWT:**
- Algorithm: HMAC-SHA256
- Claims: `sub` (user ID), `email`, `name identifier`
- Access token expires in 15 minutes
- Refresh token stored in PostgreSQL with revocation support
- On password change, all existing refresh tokens are revoked

**Demo OTP:**
The system uses a static demo verification code (`00000` by default, configurable via `DemoOtp:VerificationCode` in `appsettings.json`). In production, replace with a real SMS gateway.

**Password requirements (enforced on both frontend and backend):**
- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number

---

### 4.5 Infrastructure Services

| Service | Description |
|---------|-------------|
| `IJwtTokenService` | Generates and validates access + refresh tokens |
| `IPasswordHasherService` | Wraps ASP.NET Core `PasswordHasher<object>` (BCrypt-compatible) |
| `ICurrencyConversionService` | Converts amounts between currencies using configured rates |
| `IExchangeRateService` | Returns the rates dictionary |
| `UserCurrencyResolver` | Normalises user preferred currency |
| `TransactionCurrencyHelper` | Converts transaction amounts to base currency at creation time |
| `RecurringTransactionsBackgroundService` | Hosted service; polls every 60 minutes for due recurring rules |
| `RecurringScheduleCalculator` | Computes next run date for Daily/Weekly/Monthly/Yearly frequencies |

---

### 4.6 Configuration

**`appsettings.json` structure:**

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "<PostgreSQL connection string>"
  },
  "Jwt": {
    "Key": "<secret key — at least 32 chars>",
    "Issuer": "Qash.API",
    "Audience": "Qash.MobileApp",
    "AccessTokenExpirationMinutes": 15,
    "RefreshTokenExpirationDays": 7
  },
  "DemoOtp": {
    "VerificationCode": "00000"
  },
  "ExchangeRates": {
    "Rates": {
      "USD": 1.00,
      "EGP": 49.50,
      "EUR": 0.86,
      "GBP": 0.74,
      "JPY": 143.20
    }
  },
  "AllowedHosts": "*"
}
```

> ⚠️ **Never commit production credentials.** Use environment variables or `dotnet user-secrets` in development.

**Server port:** Set `PORT` environment variable (defaults to `8080`). The app listens on `http://*:{PORT}`.

---

## 5. Frontend — Qash.Mobile

### 5.1 Architecture

The Flutter app follows **Clean Architecture** per feature:

```
features/<name>/
  presentation/           # Screens and widgets
  domain/
    entities/             # Pure Dart models
    repositories/         # Abstract interfaces
    usecases/             # Single-responsibility operations
  data/
    *_api.dart            # Dio HTTP implementation
    datasources/          # Data source interfaces
    models/               # JSON serialization models
    repositories/         # Concrete implementations
  providers/              # Riverpod providers wiring everything together
```

**Error handling:** Uses a `Result<T>` type (`Success<T>` / `Failure<T>`) and `AppFailure` to propagate errors without exceptions across layers.

---

### 5.2 Screens & Routes

| Route | Screen | Description |
|-------|--------|-------------|
| `/` | Splash | 2-second branded loading screen |
| `/onboarding` | Onboarding | First-run intro slides |
| `/login` | Login | Phone number + password sign-in |
| `/register` | Register | Full account creation form |
| `/verify?phone=` | Verify Phone | OTP entry after registration |
| `/forgot-password` | Forgot Password | Phone number input to request reset code |
| `/forgot-verify?phone=&code=` | Forgot Verify | OTP entry for password reset |
| `/forgot-reset?phone=&code=` | Reset Password | New password entry |
| `/password-changed` | Password Changed | Success confirmation screen |
| `/change-password` | Change Password (Auth) | Change password (auth flow) |
| `/home` | Dashboard | Balance, recent transactions, quick actions |
| `/transactions` | Transactions | Transaction list with wallet filter |
| `/transactions/add?type=` | Add Transaction | Create income / expense / transfer |
| `/transactions/:id` | Transaction Detail | View transaction details |
| `/transactions/:id/delete` | Delete Confirm | Confirm transaction deletion |
| `/analytics` | Analytics | Charts: category breakdown, spending trend, income vs expense |
| `/profile` | Profile | User info, settings, navigation hub |
| `/profile/edit` | Edit Profile | Edit name, email, preferred currency |
| `/profile/settings` | Settings | Preferences |
| `/profile/change-password` | Change Password (Profile) | Entry point for change password flow |
| `/profile/change-verify` | Change Verify | OTP entry for change password |
| `/profile/change-reset` | Change Reset | New password entry (profile flow) |
| `/profile/change-success` | Change Success | Success confirmation |
| `/profile/terms` | Terms of Service | Legal |
| `/profile/privacy` | Privacy Policy | Legal |
| `/profile/delete` | Delete Account | Account deletion with password confirmation |
| `/profile/logout` | Logout Confirm | Logout confirmation dialog |
| `/profile/help` | Help & FAQ | Support information |
| `/budgets` | Budgets | Budget list with spending status |
| `/budgets/create` | Create Budget | New monthly budget |
| `/budgets/:id` | Budget Detail | Spending vs limit for a category |
| `/wallets` | Wallets | Wallet list grouped by currency |
| `/wallets/create` | Create Wallet | New wallet |
| `/wallets/:id` | Wallet Detail | Transactions from wallet perspective |
| `/goals` | Saving Goals | Goals list with progress bars |
| `/goals/create` | Create Goal | New savings goal |
| `/goals/:id` | Goal Detail | Goal progress and contributions |
| `/goals/:id/add-funds` | Add Funds | Contribute to a goal |
| `/goals/:id/delete` | Delete Goal | Confirm goal deletion |

**Bottom navigation bar:** Home · Transactions · Analytics · Goals · Profile

---

### 5.3 Features

#### Auth
Complete authentication flows: register, login, verify phone, forgot password, reset password, change password. All forms have real-time validation, inline error messages, red borders on invalid fields, and disabled submit buttons until valid.

After registration and phone verification, tokens are saved and the user is navigated directly to home — no re-login required.

#### Dashboard
Displays total balance (in preferred currency), monthly income vs expense, recent transactions (last 5), and top spending categories. Quick-action buttons for add transaction, wallets, budgets, and goals.

Multi-currency transactions are converted to the user's `PreferredCurrency` using the same rates as the backend.

#### Transactions
List view with optional wallet filter. Transactions are displayed with category icons, signed amounts (green for positive, red for negative), and transfer badges. Supports income, expense, and transfer types.

Transfer transactions are shown from the perspective of the selected wallet: outgoing = red, incoming = green.

#### Wallets
Wallet list grouped by currency with aggregate totals per currency. Wallet detail shows all transactions where that wallet is either source or destination.

#### Budgets
Monthly budgets per category. The budget list shows progress bars (spent vs limit). Each budget detail shows the spending breakdown for the month.

#### Saving Goals
Goals with target amounts, current progress, and optional deadlines. Users can add contributions directly from the goal detail screen.

#### Analytics
Four chart types powered by the Reports API:
- **Category breakdown** — pie/bar chart of spending by category
- **Income vs expense** — monthly comparison for the year
- **Spending trend** — daily spending over the last N days
- **Date range summary** — custom date range totals

#### Profile
User profile display and editing. Phone number is read-only after account creation. Includes preferred currency selection, password management flows, legal pages, and account deletion.

---

### 5.4 Core Utilities

#### Network (`lib/core/network/`)

| File | Purpose |
|------|---------|
| `auth_interceptor.dart` | Attaches `Authorization: Bearer` header; proactively refreshes token if near expiry; retries once on 401 |
| `token_refresher.dart` | Calls `POST /api/auth/refresh-token`; updates stored tokens |
| `access_token_utils.dart` | Decodes JWT to check expiry without a library |
| `api_response.dart` | Deserializes the `ApiResponse<T>` envelope |

#### Storage (`lib/core/storage/`)

Uses `flutter_secure_storage` to persist:
- `access_token`
- `refresh_token`
- `user_id`

#### Validation (`lib/core/validation/`)

| File | Rules |
|------|-------|
| `contact_validation.dart` | Email: valid format, no consecutive dots. Phone: exactly 11 digits, digits only, distinct messages for too short / too long / non-digits |
| `password_policy.dart` | Min 8 chars, 1 uppercase, 1 lowercase, 1 number; returns per-rule results for live checklist display |

#### Shared Widgets (`lib/core/widgets/`)

| Widget | Use |
|--------|-----|
| `PasswordRequirementsWidget` | Live password policy checklist (green ✓ / red •) |
| `BottomNavBar` | App-wide bottom navigation |
| `CurrencyFlag` | Currency icon/flag display |
| `TransactionCategoryIcon` | Category-aware icon with colour |

#### Currency (`lib/core/`)

- Client-side conversion aligned with the same rates as the backend
- `currency_format.dart` — formats amounts with currency symbol
- `currency_display.dart` — display helpers per currency

---

### 5.5 State Management

All state is managed with **Riverpod**. The provider graph per feature:

```
dioProvider (global Dio with AuthInterceptor)
  └── <Feature>RemoteDataSourceProvider (API layer)
        └── <Feature>RepositoryProvider (domain layer)
              └── <Feature>UseCaseProvider (use case)
                    └── <Feature>Provider (FutureProvider / StateNotifier)
                          └── Screens watch/read this
```

Session invalidation on login/logout:
```dart
invalidateUserSessionData(ref);
// Invalidates: profileProvider, walletsProvider, dashboardProvider, etc.
```

---

## 6. Database

**Engine:** PostgreSQL  
**ORM:** Entity Framework Core 8 with Npgsql

**Key design decisions:**

| Decision | Implementation |
|----------|---------------|
| Soft delete | `IsDeleted`, `DeletedAt` on `BaseEntity`; global query filters exclude deleted rows |
| Audit trail | `CreatedAt`, `UpdatedAt` on every entity |
| Precision | `decimal(18,4)` for all monetary amounts |
| Unique indexes | Email (case-insensitive, filtered), PhoneNumber (filtered), Category name per user+type, Budget per user+category+month |
| Cascade rules | User deletion cascades to wallets, transactions, tokens, categories; wallet deletion cascades to transactions |

**Schema overview:**

```
Users ──────────────────────────────────────────────┐
  │                                                   │
  ├── RefreshTokens (userId FK, cascade)              │
  ├── Wallets (userId FK, cascade)                    │
  │     └── Transactions (walletId FK, cascade) ◄─── │
  │           └── Category (categoryId FK, restrict)  │
  ├── Transactions (userId FK, cascade)               │
  ├── Categories (userId FK, cascade)                 │
  ├── Budgets (userId + categoryId FK)                │
  ├── SavingGoals (userId FK)                         │
  └── RecurringTransactions (userId + walletId + categoryId FK)
```

---

## 7. Getting Started

### 7.1 Prerequisites

| Requirement | Version |
|-------------|---------|
| .NET SDK | 8.0+ |
| Flutter SDK | 3.11+ |
| PostgreSQL | 15+ |
| Dart | 3.0+ |

---

### 7.2 Backend Setup

**1. Clone and configure:**

```bash
cd Qash.API
```

Create `appsettings.Development.json` (never commit secrets):

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=qash_db;Username=postgres;Password=yourpassword"
  },
  "Jwt": {
    "Key": "your-secret-key-minimum-32-characters-long",
    "Issuer": "Qash.API",
    "Audience": "Qash.MobileApp",
    "AccessTokenExpirationMinutes": 15,
    "RefreshTokenExpirationDays": 7
  },
  "DemoOtp": {
    "VerificationCode": "00000"
  },
  "ExchangeRates": {
    "Rates": {
      "USD": 1.00,
      "EGP": 49.50,
      "EUR": 0.86,
      "GBP": 0.74,
      "JPY": 143.20
    }
  }
}
```

**2. Apply database migrations:**

```bash
dotnet ef database update
```

**3. Run the API:**

```bash
dotnet run
# API starts at http://localhost:8080
# Swagger UI at http://localhost:8080
```

---

### 7.3 Mobile Setup

**1. Configure environment:**

Create `Qash.Mobile/qash/.env`:

```
BASE_URL=http://10.0.2.2:8080/api   # Android emulator → localhost
# BASE_URL=http://localhost:8080/api  # iOS simulator / web
# BASE_URL=http://<your-ip>:8080/api  # Physical device
```

**2. Install dependencies:**

```bash
cd Qash.Mobile/qash
flutter pub get
```

**3. Run the app:**

```bash
flutter run
```

**4. (Optional) Run code generation:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 8. API ↔ Mobile Coverage

| Backend Feature | Mobile | Notes |
|-----------------|--------|-------|
| Auth — Register / Login / Logout | ✅ | Logout is client-side only (token cleared locally) |
| Auth — Verify Phone | ✅ | Uses demo OTP `00000` |
| Auth — Forgot / Reset Password | ✅ | |
| Auth — Change Password | ✅ | Available from both auth and profile flows |
| Auth — Refresh Token | ✅ | Handled automatically by interceptor |
| Profile — Get / Update | ✅ | Phone number read-only after creation |
| Profile — Delete Account | ✅ | |
| Dashboard | ✅ | |
| Transactions — Create / List / Detail / Delete | ✅ | |
| Transactions — Update | ❌ | API exists, not wired in mobile |
| Wallets — Full CRUD | ✅ | |
| Budgets — Create / List / Status / Delete | ✅ | |
| Budgets — Update | ❌ | API exists, not wired in mobile |
| Saving Goals — Full CRUD + Contribute | ✅ | |
| Categories — List | ✅ | Create / Update / Delete not exposed in UI |
| Reports / Analytics | ✅ | |
| Exchange Rates | ✅ | Used for client-side currency conversion |
| Recurring Transactions | ❌ | API + backend processing exists; no mobile UI |
| Insights | ❌ | API exists; no mobile UI |
| Export (CSV / PDF) | ❌ | API exists; no mobile UI |

---

## 9. Validation Rules

These rules are enforced on **both** the frontend (real-time, inline) and the backend (FluentValidation).

### Email
- Required
- Valid format (`user@domain.tld`)
- No consecutive dots (`..`)
- No missing `@`, domain, or TLD

### Phone Number
- Required
- Exactly **11 digits** — digits only
- Error messages:
  - Less than 11 digits → `"Phone number must contain 11 digits."`
  - More than 11 digits → `"Phone number cannot exceed 11 digits."`
  - Non-digit characters → `"Phone number must contain digits only."`

### Password
- Minimum **8 characters**
- At least **1 uppercase** letter
- At least **1 lowercase** letter
- At least **1 number**
- Live checklist shown below the field during typing

### Confirm Password
- Must exactly match the password field
- Immediate mismatch feedback shown below the field

### Verification Code (OTP)
- Exactly **5 digits** — digits only
- Demo code: **`00000`**

### Validation UI behaviour (all screens)
- Red border on the field when invalid
- Error message shown directly below the field
- Validation triggers on every keystroke (real-time)
- Submit button disabled until all fields are valid
- Disabled button colour: `#9CA3AF` (grey)

---

## 10. Known Limitations & Future Work

### Security (for production)
- Replace the hardcoded demo OTP (`00000`) with a real SMS gateway (Twilio, etc.)
- Rotate the JWT secret key and store it in environment variables / a secrets manager
- Remove `RequireHttpsMetadata = false` — enforce HTTPS in production
- Replace wildcard CORS (`AllowAnyOrigin`) with a specific allowed-origins list
- Disable Swagger UI in production
- Add rate limiting on auth endpoints (login, register, forgot-password)
- Add missing database indexes on `TransactionDate`, `ApplicationUserId`, `TransferGroupId`

### Features not yet in mobile
- Recurring transaction management UI
- Spending insights / tips screen
- CSV and PDF export
- Transaction editing (update)
- Budget editing (update)
- Category management UI (create / edit / delete)

### Code quality
- `HomeScreen` and `AddTransactionScreen` are large "God Widgets" (~1600 and ~900 lines respectively) — could be decomposed into sub-widgets
- No automated tests (unit, widget, or integration) beyond the placeholder widget test
- Client-side logout does not call `POST /api/auth/logout` to revoke the refresh token server-side
- `hive` is listed as a dependency but not currently used

---

## License

This project was built as a university assignment at AAST (Arab Academy for Science, Technology and Maritime Transport) for the Mobile Applications course, Semester 10.
