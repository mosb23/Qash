# 🚀 Qash.API

![.NET](https://img.shields.io/badge/.NET-8-purple)
![ASP.NET Core](https://img.shields.io/badge/ASP.NET_Core-Web_API-blue)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16%2B-336791)
![Status](https://img.shields.io/badge/Status-Active-success)

Backend REST API for **Qash**, a university mobile expense tracker application.

Built using **ASP.NET Core Web API (.NET 8)** with **PostgreSQL**, **JWT Authentication**, **Refresh Tokens**, **CQRS**, **MediatR**, **FluentValidation**, and **Swagger**.

---

## 📌 Project Overview

Qash helps users manage their personal finances through a modern mobile app.

Users can:

- Track expenses & income
- Manage wallets/accounts
- Secure authentication
- Manage profile
- Reset password with OTP flow
- Use budgets & goals (next phase)
- Reports & analytics (next phase)

This repository contains the full backend API.

---

## 🛠 Tech Stack

| Technology | Version |
| --- | --- |
| .NET | 8 |
| ASP.NET Core Web API | 8 |
| PostgreSQL | 16+ |
| Entity Framework Core | 8.0.11 |
| Npgsql | 8.0.11 |
| MediatR | 12.4.1 |
| FluentValidation | 11.11.0 |
| Swagger | 6.9.0 |
| AutoMapper | 12.0.1 |

---

## 🧱 Architecture

```text
Qash.API/
├── Controllers/
├── Domain/
│   ├── Common/
│   ├── Entities/
│   └── Enums/
├── Infrastructure/
│   ├── Data/
│   ├── Authentication/
│   ├── Mapping/
│   └── Services/
├── Features/
│   ├── Auth/
│   └── Profile/
├── Common/
└── Program.cs
```

---

## ✅ Implemented Modules

### Authentication

- Register
- Phone Verification
- Login
- Refresh Token
- Logout
- Forgot Password
- Change Password

### Profile

- Get Profile
- Update Profile
- Soft Delete Profile

---

## 🔐 Authentication Flow

1. User registers account using personal information.
2. Account is created with unverified phone number.
3. User verifies phone number using OTP code.
4. User logs in after successful verification.
5. JWT + Refresh Token issued.

---

## 📲 Demo OTP

For development / academic use:

```text
00000
```

Used in:

- Phone verification
- Forgot password
- Change password

> In production, OTP should be sent through Firebase / Twilio / SMS provider.

---

## ⚙️ Setup Guide

### 1) Clone Repository

```bash
git clone https://github.com/mosb23/Qash.API.git
cd Qash.API
```

### 2) Install Requirements

- .NET 8 SDK
- PostgreSQL 16+
- Visual Studio / VS Code

### 3) Configure Database

Edit `appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Host=localhost;Port=5432;Database=QashDb;Username=postgres;Password=YOUR_PASSWORD"
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
```

Rates are **units of each currency per 1 USD** (for example, 1 USD = 49.50 EGP). Wallet transfers between different currencies use these rates automatically.

### 4) Apply Migration

```bash
dotnet ef database update
```

### 5) Run Project

```bash
dotnet run
```

Swagger:

```text
http://localhost:xxxx/swagger
```

---

## 📬 API Endpoints

### Auth

| Method | Endpoint |
| --- | --- |
| POST | `/api/auth/register` |
| POST | `/api/auth/verify-phone` |
| POST | `/api/auth/login` |
| POST | `/api/auth/refresh-token` |
| POST | `/api/auth/logout` |
| POST | `/api/auth/forgot-password/request-code` |
| POST | `/api/auth/forgot-password/reset` |
| POST | `/api/auth/change-password` |

### Profile

| Method | Endpoint |
| --- | --- |
| GET | `/api/profile` |
| PUT | `/api/profile` |
| DELETE | `/api/profile` |

---

## 📄 Sample Register Request

```json
{
  "firstName": "Mohamed",
  "lastName": "Ahmed",
  "email": "mohamed@gmail.com",
  "phoneNumber": "01028239305",
  "password": "Password123",
  "confirmPassword": "Password123"
}
```

## 📄 Verify Phone Request

```json
{
  "phoneNumber": "01028239305",
  "verificationCode": "00000"
}
```

### Verify Phone

`POST /api/auth/verify-phone`

---

## 📄 Sample Login Request

```json
{
  "phoneNumber": "01028239305",
  "password": "Password123"
}
```

---

## 🗄 Database Tables

### `Users`

- `Id`
- `FirstName`
- `LastName`
- `Email`
- `PhoneNumber`
- `PasswordHash`
- `CreatedAt`
- `UpdatedAt`
- `IsDeleted`
- `DeletedAt`

### `RefreshTokens`

- `Id`
- `Token`
- `ExpiresAt`
- `IsRevoked`
- `RevokedAt`

---

## 🔒 Security

- Password Hashing
- JWT Authentication
- Refresh Token Rotation
- Soft Delete Users
- Protected Endpoints

---

## 🚧 Next Modules

- Categories
- Wallets
- Transactions
- Budgets
- Saving Goals
- Reports
- Recurring Transactions

---

University Mobile App  Project
