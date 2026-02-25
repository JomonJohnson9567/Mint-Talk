# Implementation Plan for Mint Talk App Refactoring

This document outlines the step-by-step implementation plan to elevate the Mint Talk app to production-ready quality, based on the previous architectural and code quality analysis.

## Phase 1: Quick Wins & Code Quality (Immediate)

**Goal:** Resolve all static analysis warnings and ensure the UI uses the responsive sizing correctly.

### 1.1 Fix Deprecation Warnings (`Color.withOpacity`)
*   **Action:** Run `flutter analyze`.
*   **Implementation:** 
    *   Search globally for all instances of `.withOpacity(`.
    *   Replace them with the appropriate `.withAlpha()` method (e.g., `Colors.black.withOpacity(0.5)` -> `Colors.black.withAlpha(128)`).
    *   Ensure `flutter analyze` returns 0 issues.

### 1.2 Implement ScreenUtil Responsiveness Globally
*   **Action:** Enforce ScreenUtil properties across all UI files.
*   **Implementation:**
    *   Find hardcoded dimensions (e.g., `height: 24`, `width: 10`, `radius: 60`, `fontSize: 16`).
    *   Update height/width spacing: Use `.h` for heights and `.w` for widths.
    *   Update textual sizes: Use `.sp` (scaled pixels) for fonts.
    *   Update radiuses/border styling: Use `.r` for corner radii.

## Phase 2: Decoupling State Management & Establishing DI (Short-Term)

**Goal:** Ensure Blocs/Cubits are pure Dart code and set up Dependency Injection.

### 2.1 Remove UI Dependencies from Cubits
*   **Action:** Refactor `HomeCubit` (and any other state logic) to prevent it from emitting Flutter specific classes (like `Color`).
*   **Implementation:**
    *   Remove `dart:ui` or `flutter/material.dart` imports from all files inside `bloc` or `cubit` folders.
    *   Instead of `notificationColor = AppColors.termsIcon`, emit an enum (e.g., `NotificationType.info` or `NotificationType.warning`).
    *   Inside the UI (`BlocBuilder`), map the enum back to the correct `Color`.

### 2.2 Setup Dependency Injection Container
*   **Action:** Introduce `get_it` and `injectable`.
*   **Implementation:**
    *   Add `get_it` and `injectable` to `pubspec.yaml`.
    *   Create a `service_locator.dart` (or `injection.dart`) inside `lib/core/di/`.
    *   Register singletons and factory instances (e.g., `GetIt.I.registerFactory(() => CallScreenCubit());`).
    *   Refactor `app_router.dart` so it retrieves Cubits via `getIt<MyCubit>()` instead of instantiating them directly.

## Phase 3: Completing Clean Architecture (Mid-Term)

**Goal:** Provide a solid data access layer rather than mocking data directly in the Bloc.

### 3.1 Establish the Domain Layer
*   **Action:** Create abstraction rules.
*   **Implementation:**
    *   In features (e.g., `home/domain/`), add a `repositories/` folder.
    *   Create `abstract class HomeRepository { Future<List<HomeUserEntity>> getUsers(); }`

### 3.2 Establish the Data Layer
*   **Action:** Implement data fetching.
*   **Implementation:**
    *   In `home/data/`, add `models/` (Data Transfer Objects), `datasources/` (API logic using Dio/Http), and `repositories/` (Implementation of the domain abstract class).
    *   Move the mock data currently inside `HomeCubit` out into a `MockHomeDatasource`.

### 3.3 Inject Repositories into Cubits
*   **Action:** Refactor Cubits to rely on data layers.
*   **Implementation:**
    *   Update `HomeCubit` to accept `HomeRepository` in its constructor.
    *   Update DI pipeline (`get_it`) to pass the repository into the Cubit when instantiated.

## Phase 4: Modern Navigation & Testing (Long-Term)

**Goal:** Migrate to a declarative routing system and write tests to prevent regressions.

### 4.1 Migrate to go_router (Navigator 2.0)
*   **Action:** Replace `Navigator 1.0` logic.
*   **Implementation:**
    *   Add `go_router` to `pubspec.yaml`.
    *   Convert `app_router.dart` from `onGenerateRoute` logic to a declarative `GoRouter` configuration.
    *   Handle route guards (e.g., redirect unauthenticated users away from private screens).

### 4.2 Establish Automated Testing
*   **Action:** Add Unit Tests.
*   **Implementation:**
    *   Add `mocktail` and `bloc_test` packages.
    *   Write tests for `HomeCubit` and `CallScreenCubit` validating states (`Loading -> Success`, `Empty`, `Error`).
    *   Write Mock Repository tests to verify data fetching logic.
