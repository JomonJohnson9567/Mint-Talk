# Mint Talk — Flutter Application
## Product Requirements Document (PRD)

| | |
|---|---|
| **Document Type** | Product Requirements Document — Frontend (Flutter/Dart) |
| **Product** | Mint Talk Mobile Application |
| **Platform** | Flutter (iOS & Android) |
| **State Management** | BLoC (`flutter_bloc`) |
| **Backend Reference** | Mint Talk Backend API Documentation v1 (March 6, 2026) |
| **Base URL** | `https://mint-talk-backend.onrender.com/api/v1` |
| **Document Version** | 1.0 |
| **Status** | Draft for Engineering Review |
| **Classification** | Confidential — Internal Use Only |

---

## 1. Overview

### 1.1 Purpose
This PRD defines the functional and technical requirements for building the **Mint Talk Flutter client application**, which consumes the existing Mint Talk Backend API. The document translates each backend endpoint into a corresponding **feature module**, specifies the **BLoC architecture** (Events, States, Blocs/Cubits) required to drive it, and defines the UI/UX, data, and non-functional requirements needed for a production-quality implementation.

### 1.2 Background
Mint Talk is a phone-OTP-based platform where users purchase point-based recharge plans (via Razorpay), maintain a points wallet, and can earn referral rewards. An admin panel-facing role (Admin / Super Admin) manages plans, wallets, and recharge oversight. The backend is fully implemented; this PRD scopes the **Flutter consumer application** (and, where relevant, the **Admin companion flows**) that will integrate with it.

### 1.3 Goals
- Deliver a resilient, secure Flutter client with full coverage of all documented API endpoints.
- Standardize state management using **BLoC pattern** with clear separation of Data, Domain, and Presentation layers.
- Normalize inconsistent backend response formats (`success` vs `status` fields) into a single internal contract.
- Provide a robust token-refresh and session-management strategy using access + HTTP-only refresh tokens.
- Ensure predictable error handling and retry behavior across the app.

### 1.4 Out of Scope
- Backend/API changes (API is treated as a fixed contract).
- Payment gateway backend logic (only Razorpay Flutter SDK client-side integration is in scope).
- Web/desktop clients (Flutter mobile only, extensible to web later).

---

## 2. User Roles

| Role | Description | App Surface |
|---|---|---|
| `client` | Standard end user; signs up via OTP, purchases plans, manages wallet | Consumer App |
| `admin` | Manages plans, wallets, recharges | Admin Module (in-app or separate flavor) |
| `super_admin` | Full access incl. admin account management | Admin Module |

---

## 3. Technical Architecture

### 3.1 Architectural Pattern
**Clean Architecture + BLoC**, structured in three layers:

```
lib/
├── core/
│   ├── network/            # Dio client, interceptors, token refresh
│   ├── error/               # Failure classes, exception mapping
│   ├── constants/           # API endpoints, storage keys
│   ├── utils/                # Validators, formatters
│   └── theme/
├── data/
│   ├── datasources/          # Remote data sources (per feature)
│   ├── models/                # DTOs (fromJson/toJson)
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/              # Pure Dart business objects
│   ├── repositories/          # Abstract repository contracts
│   └── usecases/               # Single-responsibility use cases
├── presentation/
│   ├── auth/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   ├── profile/
│   ├── plans/
│   ├── wallet/
│   ├── payments/
│   ├── admin/
│   └── common/
└── main.dart
```

### 3.2 Tech Stack

| Layer | Technology |
|---|---|
| Language | Dart (SDK ≥ 3.x), Flutter ≥ 3.19 |
| State Management | `flutter_bloc` / `bloc` |
| Networking | `dio` (interceptors for auth + refresh) |
| DI | `get_it` + `injectable` |
| Local Storage | `flutter_secure_storage` (tokens), `shared_preferences` (non-sensitive flags) |
| Cookie Handling | `dio_cookie_manager` + `cookie_jar` (required for HTTP-only `refreshToken` cookie) |
| Routing | `go_router` |
| Payments | `razorpay_flutter` |
| Functional Error Handling | `dartz` (`Either<Failure, T>`) or `fpdart` |
| Equality | `equatable` |
| Code Generation | `freezed`, `json_serializable` |
| Testing | `bloc_test`, `mocktail`, `flutter_test` |

### 3.3 BLoC Design Principles
1. Every feature has its own **Bloc/Cubit** — no shared "God Bloc."
2. **Events** represent user intent (`SendOtpRequested`, `VerifyOtpRequested`).
3. **States** are immutable, generated via `freezed`, and follow a consistent shape:
   - `Initial`
   - `Loading`
   - `Success` (with payload)
   - `Failure` (with `Failure` object: message, code)
4. Blocs call **UseCases**, never repositories or Dio directly.
5. Cross-cutting session state (login status, access token presence) lives in a global `AuthBloc`/`SessionCubit` exposed via `BlocProvider` at the app root; feature Blocs listen to it via `BlocListener`/repository injection rather than duplicating auth logic.
6. Pagination (e.g., Admin Recharges) uses a dedicated `PaginationState` pattern with `hasReachedMax`.

### 3.4 Networking & Session Contract

**Backend inconsistency to normalize:** responses use either `{ success: true/false }` or `{ status: "success"|"error" }`. A single `ApiResponseParser` utility in `core/network` inspects the raw JSON and maps both shapes into one internal `ApiResult<T>` object before it ever reaches a repository.

**Required request configuration (every call):**
```dart
Dio()
  ..options.baseUrl = 'https://mint-talk-backend.onrender.com/api/v1'
  ..interceptors.add(CookieManager(cookieJar))   // withCredentials equivalent
  ..interceptors.add(AuthInterceptor(secureStorage));
```

**Auth Interceptor responsibilities:**
- Attach `Authorization: Bearer <accessToken>` to all protected requests.
- On `401`/`403` response: pause the failed request, call `POST /auth/refresh-token` (cookie-based), update stored access token, retry the original request once. If refresh fails → dispatch `SessionExpired` event, force logout, clear secure storage, navigate to login.
- Special case: `POST /admin/admin-login` returns the access token in the **response header** (`Authorization`), not the body — the interceptor/datasource must read `response.headers['authorization']`.

---

## 4. Feature Requirements & BLoC Specification

For each backend module, the table below lists endpoints, and each is followed by its BLoC contract (Events → States → UseCases) and functional requirements.

### 4.1 Health Check Module

| Method | Endpoint | Auth |
|---|---|---|
| GET | `/health` (outside `/api/v1`) | None |

**Purpose:** App-launch connectivity probe / splash screen check; optional "server unreachable" banner.

**Bloc:** `HealthCheckCubit`
- States: `HealthInitial`, `HealthChecking`, `HealthOk(timestamp)`, `HealthUnreachable`

---

### 4.2 Authentication Module

| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/send-otp` | Send OTP via Twilio |
| POST | `/auth/verify-otp` | Verify OTP, login/signup, sets `refreshToken` cookie |
| POST | `/auth/refresh-token` | Refresh access token |
| POST | `/auth/logout` | Invalidate session |

**Screens:** Phone Entry → OTP Verification → (new user) Profile Setup, or (existing user) Home.

**Bloc:** `AuthBloc`

**Events:**
- `SendOtpRequested(phone, countryCode)`
- `VerifyOtpRequested(phone, countryCode, otp)`
- `RefreshTokenRequested`
- `LogoutRequested`
- `AutoLoginChecked` (app start — checks secure storage for existing session)

**States:**
- `AuthInitial`
- `OtpSending` / `OtpSent` / `OtpSendFailure(message)`
- `OtpVerifying` / `AuthAuthenticated(user, accessToken)` / `OtpVerifyFailure(message)`
- `AuthUnauthenticated`
- `SessionExpired`

**Functional Requirements:**
- FR-1.1: Phone input restricted to numeric, validated with `countryCode` selector (default `+91`).
- FR-1.2: Handle `429` on send-otp with a visible cooldown/backoff timer (rate-limited state).
- FR-1.3: OTP field: 6-digit input, auto-submit on completion, resend-OTP timer (e.g., 30s).
- FR-1.4: On `verify-otp` success, persist `accessToken` in secure storage; `refreshToken` cookie is persisted automatically by the cookie jar.
- FR-1.5: If `user.profileCompleted == false`, route to Profile Setup; else route to Home.
- FR-1.6: `401 – Invalid OTP` → inline field error, no navigation.
- FR-1.7: Logout clears secure storage, cookie jar, and resets all feature Blocs' cached state (via `SessionCubit` broadcast).

---

### 4.3 User Module

| Method | Endpoint | Description |
|---|---|---|
| PATCH | `/user/profile` | Complete/update profile |
| GET | `/user/referral-verify` | Validate referral code |

**Screens:** Profile Setup / Edit Profile.

**Bloc:** `ProfileBloc` (+ `ReferralValidationCubit` for the referral field's live validation)

**Events:**
- `ProfileSubmitted(fullName, dob, gender, referralCode?, termsAcceptedAt)`
- `ReferralCodeChanged(code)` (debounced, calls `/user/referral-verify`)

**States:**
- `ProfileInitial`, `ProfileSubmitting`, `ProfileSaved(userData)`, `ProfileValidationError(fieldErrors)`, `ProfileSubmitFailure(message)`
- `ReferralIdle`, `ReferralChecking`, `ReferralValid`, `ReferralInvalid`

**Functional Requirements:**
- FR-2.1: Client-side validation mirrors backend rules before submit:
  - `fullName`: 5–50 chars
  - `dob`: valid date, user must be ≥ 18 (compute client-side, block submit if under 18 with clear message)
  - `gender`: enum `male|female|other` (segmented control / dropdown)
  - `referralCode`: optional, uppercase alphanumeric/hyphen, 4–15 chars, auto-uppercase as typed
  - `termsAcceptedAt`: set to current ISO timestamp only after user checks a mandatory Terms checkbox
- FR-2.2: Referral code field debounces input (400ms) and calls `GET /user/referral-verify` showing inline check/cross icon.
- FR-2.3: On `201` success, update the global `SessionCubit` user object (`profileCompleted: true`) and navigate to Home.
- FR-2.4: `400` validation errors from backend are mapped field-by-field where the API indicates a field name; otherwise shown as a general form error.

---

### 4.4 Plans Module

| Method | Endpoint | Auth |
|---|---|---|
| GET | `/plans` | Public (filtered) / Admin (all) |
| GET | `/plans/:planId` | Public / Admin |
| POST | `/plans` | admin, super_admin |
| PATCH | `/plans/:planId` | admin, super_admin |
| DELETE | `/plans/:planId` | admin, super_admin (soft toggle) |

**Screens:** Plan Listing (consumer), Plan Detail, Admin: Plan Management (create/edit/list with active toggle).

**Bloc:** `PlansBloc` (consumer listing) + `PlanDetailCubit` + `AdminPlansBloc` (CRUD, admin-only)

**Events (`PlansBloc`):**
- `PlansRequested` (initial fetch)
- `PlansRefreshed` (pull-to-refresh)

**States (`PlansBloc`):**
- `PlansLoading`, `PlansLoaded(List<Plan>)`, `PlansEmpty`, `PlansFailure(message)`

**Events (`AdminPlansBloc`):**
- `AdminPlanCreated(name, price, country, currency, points, bonusPoints, isActive)`
- `AdminPlanUpdated(planId, patchFields)`
- `AdminPlanToggled(planId)` — calls DELETE (soft toggle)

**States (`AdminPlansBloc`):**
- `AdminPlansLoading`, `AdminPlansLoaded`, `AdminPlanMutationInProgress`, `AdminPlanMutationSuccess(message)`, `AdminPlanMutationFailure(message)`

**Functional Requirements:**
- FR-3.1: Plan card displays: name, price, currency, points, bonus points, and an "active" badge (admin view only — public view only ever receives active plans).
- FR-3.2: Consumer Plan Detail screen is the entry point to the Payments flow (`Buy Now` → `create-order`).
- FR-3.3: Admin Delete action must be labeled **"Deactivate/Activate"** in UI, never "Delete," since the endpoint is a soft toggle — copy must not imply permanent deletion.
- FR-3.4: Admin create/edit form validates numeric fields (`price`, `points`, `bonusPoints` ≥ 0) client-side before submission.

---

### 4.5 Wallet Module

| Method | Endpoint | Description |
|---|---|---|
| POST | `/wallet/initialize` | Create/get wallet |
| GET | `/wallet/:userId/balance` | Get balance |
| POST | `/wallet/credit` | Admin manual credit |
| POST | `/wallet/debit` | Admin manual debit |
| GET | `/wallet/:userId/recharge-history` | Recharge history |
| GET | `/wallet/:userId/referral-status` | Referral reward status |

**Screens:** Wallet Home (balance + quick actions), Recharge History (paginated list), Referral Status card, Admin Wallet Adjustment.

**Bloc:** `WalletBloc`

**Events:**
- `WalletInitialized` (called post-login/first-launch)
- `WalletBalanceRequested(userId)`
- `RechargeHistoryRequested(userId)`
- `ReferralStatusRequested(userId)`

**States:**
- `WalletLoading`
- `WalletLoaded(balance, status)`
- `RechargeHistoryLoaded(List<Transaction>)`
- `ReferralStatusLoaded(ReferralData?)` — must gracefully render the "no referral yet" empty state when `referralData == null`
- `WalletFailure(message)`

**Admin sub-bloc:** `AdminWalletAdjustmentBloc`
- Events: `CreditRequested(userId, amount, purpose, referenceId)`, `DebitRequested(userId, amount, purpose, referenceId)`
- States: `AdjustmentSubmitting`, `AdjustmentSuccess`, `AdjustmentFailure(message)`

**Functional Requirements:**
- FR-4.1: `wallet/initialize` is called automatically once after first successful profile completion / on app start if no local wallet cache exists — idempotent per API contract (returns existing wallet).
- FR-4.2: Balance is displayed in **points**, not currency; a helper util (`PointsFormatter`) formats large numbers with grouping (e.g., `1,20,000` for Indian locale).
- FR-4.3: Recharge history list uses infinite scroll / pull-to-refresh; each row shows amount, currency, points, status chip (color-coded: completed = green, pending = amber).
- FR-4.4: Referral status card shows reward points and a `REWARDED`/pending badge; null state shows a CTA to share referral code.
- FR-4.5: `:userId` route param resolution: consumer screens always pass the logged-in user's own ID from `SessionCubit`; admin screens allow selecting any user ID.

---

### 4.6 Payments Module (Razorpay)

| Method | Endpoint | Description |
|---|---|---|
| POST | `/payments/create-order` | Create Razorpay order |
| POST | `/payments/verify` | Verify payment, credit wallet |
| POST | `/payments/webhook` | Server-only — **not called from app** |

**Screens:** Checkout/Order Summary, Razorpay Checkout (native SDK sheet), Payment Success/Failure.

**Bloc:** `PaymentBloc`

**Events:**
- `OrderCreationRequested(planId)`
- `RazorpayCheckoutOpened(orderId, amount, currency, key)`
- `PaymentSuccessReceived(razorpayOrderId, razorpayPaymentId, razorpaySignature, transactionId)`
- `PaymentErrorReceived(code, message)`
- `PaymentExternalWalletSelected(walletName)`

**States:**
- `OrderCreating`, `OrderCreated(orderId, amount, currency, planName, pointsToCredit, transactionId, key)`, `OrderCreationFailure(message)`
- `PaymentVerifying`
- `PaymentVerified(newBalance)` — covers both "new payment" and "already processed" backend responses identically
- `PaymentFailed(message)`

**Functional Requirements:**
- FR-5.1: `create-order` response's `key` field is the Razorpay key ID and must be passed directly into `razorpay_flutter`'s checkout options — never hardcoded client-side.
- FR-5.2: On Razorpay SDK success callback, immediately dispatch `PaymentSuccessReceived` to call `/payments/verify`; do **not** treat the Razorpay SDK success alone as proof of payment — the wallet is only credited after backend verification.
- FR-5.3: `/payments/webhook` must **never** be called or referenced from the Flutter app; it exists purely for Razorpay-to-server callbacks.
- FR-5.4: On `PaymentVerified`, refresh `WalletBloc` balance (dispatch `WalletBalanceRequested`) and show a success screen with `newBalance` and points credited.
- FR-5.5: Handle Razorpay SDK's own `onPaymentError` and `onExternalWallet` callbacks distinctly from backend verification failures — display appropriate, distinct copy for "payment cancelled/failed at gateway" vs. "payment succeeded but verification failed" (the latter should prompt a retry-verify or support-contact flow, since the money may have moved).
- FR-5.6: Persist `transactionId` locally until verification completes, to support retry-verify without re-creating the order.

---

### 4.7 Admin Module

| Method | Endpoint | Auth |
|---|---|---|
| POST | `/admin/admin-login` | Public (admin credentials) |
| POST | `/admin/create-admin` | super_admin |
| POST | `/admin/block-admin` | super_admin |
| POST | `/admin/unblock-admin` | super_admin |
| GET | `/admin/get-all-admins` | super_admin |
| POST | `/admin/logout` | admin, super_admin |
| GET | `/admin/recharges` | admin, super_admin |
| GET | `/admin/recharges/:transactionId` | admin, super_admin |

**Screens:** Admin Login, Admin Dashboard, Admin Management (super_admin only), Recharge Transactions (paginated + filterable), Recharge Detail.

**Bloc:** `AdminAuthBloc`, `AdminManagementBloc`, `AdminRechargesBloc`

**`AdminAuthBloc` Events/States:**
- Events: `AdminLoginRequested(email, password)`, `AdminLogoutRequested`
- States: `AdminLoginLoading`, `AdminAuthenticated(adminEmail, fullName)`, `AdminLoginFailure(message)`
- **Critical implementation note:** access token must be extracted from the **response header**, not the JSON body, via a dedicated `AdminAuthDataSource` that reads `response.headers.value('authorization')`.

**`AdminManagementBloc` Events/States:**
- Events: `AdminCreated(fullName, email, password)`, `AdminBlocked(adminId)`, `AdminUnblocked(adminId)`, `AllAdminsRequested`
- States: `AdminListLoading`, `AdminListLoaded(List<AdminAccount>)`, `AdminMutationInProgress`, `AdminMutationSuccess`, `AdminMutationFailure(message)`
- FR-6.1: Client validation mirrors backend: `fullName` ≥ 3 chars; `email` valid format; `password` ≥ 6 chars with ≥1 uppercase + ≥1 special character (regex-validated before submit).
- FR-6.2: Block/unblock actions require a confirmation dialog. Map `403 – Cannot block self` and `403 – target is not admin role` to specific inline error messages rather than a generic failure toast.

**`AdminRechargesBloc` Events/States:**
- Events: `RechargesRequested({status, userId, page, limit})`, `RechargesFiltersChanged(status, userId)`, `RechargeDetailRequested(transactionId)`
- States: `RechargesLoading`, `RechargesLoaded(items, pagination)`, `RechargesLoadingMore`, `RechargesFailure(message)`, `RechargeDetailLoaded(transaction, wallet)`, `RechargeDetailNotFound`
- FR-6.3: Recharge list implements server-side pagination (`page`, `limit`, max `limit=100`) with infinite scroll; filter chips for `status` (`pending|processing|completed`) and a `userId` search field.
- FR-6.4: Recharge Detail screen handles `404 – Recharge transaction not found` with a dedicated empty/error state, not a generic error screen.

---

## 5. Cross-Cutting Non-Functional Requirements

### 5.1 Error Handling
- All Dio exceptions are mapped in `core/error/exception_mapper.dart` into typed `Failure` subclasses: `NetworkFailure`, `ValidationFailure(fieldErrors)`, `AuthFailure`, `ServerFailure`, `RateLimitFailure(retryAfter)`, `NotFoundFailure`, `ForbiddenFailure`.
- Every Bloc's failure state carries a `Failure` object (not a raw string) so the UI layer can render context-specific messaging (e.g., `RateLimitFailure` renders a countdown; `ValidationFailure` maps to form fields).
- Status code table (Section 9 of API docs) is implemented centrally; `500`/network-timeout responses trigger the shared `RetryBanner` widget with exponential backoff (base 1s, factor 2, max 3 retries) for idempotent `GET` requests only. Non-idempotent `POST` calls (payments, wallet credit/debit) **never** auto-retry — user-initiated retry only.

### 5.2 Security
- Access token stored only in `flutter_secure_storage` (Keychain/Keystore-backed); never in `shared_preferences` or plain memory beyond the current session object.
- Refresh token is never handled directly by app code — it's an HTTP-only cookie managed by the cookie jar.
- All admin-role screens are gated behind a route guard checking the cached role claim; sensitive admin actions (block/unblock, credit/debit) require re-confirmation dialogs.
- No sensitive data (tokens, OTPs) is logged in release builds; use a build-flavor-aware logger.

### 5.3 Offline / Connectivity
- `connectivity_plus` monitors network state; feature Blocs expose a `NoConnection` state variant where relevant (Wallet, Plans, Recharges) rather than surfacing raw Dio errors.

### 5.4 Performance
- Plan and Wallet data cached in-memory per session; explicit pull-to-refresh or TTL-based cache invalidation (5 min) rather than refetching on every screen visit.
- Recharge history and admin recharges use paginated lazy-loading, not full-list fetches.

### 5.5 Localization & Formatting
- Currency/points formatting is locale-aware (`intl` package), defaulting to `en_IN` given `INR`/`IN` sample data, extensible to other `country`/`currency` combinations already supported by the Plans schema.

### 5.6 Accessibility
- Minimum tap target 48x48dp, semantic labels on all interactive elements (OTP fields, buttons, status chips), color is never the sole indicator of transaction status (icon + text accompany color coding).

---

## 6. State Diagram Summary (Illustrative)

```
AuthBloc:      Initial → OtpSending → OtpSent → OtpVerifying → Authenticated
                                                        ↘ OtpVerifyFailure
Session:       Authenticated → (401/403 + refresh fail) → SessionExpired → Unauthenticated

ProfileBloc:   Initial → Submitting → Saved
                              ↘ ValidationError / SubmitFailure

PaymentBloc:   OrderCreating → OrderCreated → (Razorpay SDK) → PaymentVerifying → PaymentVerified
                                                                        ↘ PaymentFailed
```

---

## 7. Acceptance Criteria (Sample — Authentication)

| ID | Criteria |
|---|---|
| AC-1 | Given a valid phone number, when the user requests an OTP, the app calls `POST /auth/send-otp` and transitions to `OtpSent`, starting a 30s resend cooldown. |
| AC-2 | Given a `429` response, the app displays a rate-limit message with a countdown derived from response metadata (or a default backoff), and disables the resend button until expiry. |
| AC-3 | Given a correct OTP, the app stores the access token securely, receives the `refreshToken` cookie transparently, and routes to Profile Setup or Home based on `profileCompleted`. |
| AC-4 | Given an access token expires mid-session, the Auth interceptor silently refreshes via `/auth/refresh-token` and retries the original request without user-visible interruption. |
| AC-5 | Given the refresh token is invalid/expired, the app clears all local session data and navigates to the login screen with a "session expired" message. |

*(Equivalent acceptance criteria tables should be authored per module during sprint planning; this section provides the required format/template.)*

---

## 8. Full Endpoint-to-Bloc Traceability Matrix

| Endpoint | Method | Bloc | Screen(s) |
|---|---|---|---|
| `/health` | GET | `HealthCheckCubit` | Splash |
| `/auth/send-otp` | POST | `AuthBloc` | Phone Entry |
| `/auth/verify-otp` | POST | `AuthBloc` | OTP Verification |
| `/auth/refresh-token` | POST | `AuthBloc` (interceptor-driven) | Global |
| `/auth/logout` | POST | `AuthBloc` | Settings/Profile |
| `/user/profile` | PATCH | `ProfileBloc` | Profile Setup/Edit |
| `/user/referral-verify` | GET | `ReferralValidationCubit` | Profile Setup |
| `/plans` | GET | `PlansBloc` / `AdminPlansBloc` | Plan Listing, Admin Plans |
| `/plans/:planId` | GET | `PlanDetailCubit` | Plan Detail |
| `/plans` | POST | `AdminPlansBloc` | Admin Create Plan |
| `/plans/:planId` | PATCH | `AdminPlansBloc` | Admin Edit Plan |
| `/plans/:planId` | DELETE | `AdminPlansBloc` | Admin Plan List (toggle) |
| `/wallet/initialize` | POST | `WalletBloc` | App bootstrap |
| `/wallet/:userId/balance` | GET | `WalletBloc` | Wallet Home |
| `/wallet/credit` | POST | `AdminWalletAdjustmentBloc` | Admin Wallet Adjustment |
| `/wallet/debit` | POST | `AdminWalletAdjustmentBloc` | Admin Wallet Adjustment |
| `/wallet/:userId/recharge-history` | GET | `WalletBloc` | Recharge History |
| `/wallet/:userId/referral-status` | GET | `WalletBloc` | Referral Status |
| `/payments/create-order` | POST | `PaymentBloc` | Checkout |
| `/payments/verify` | POST | `PaymentBloc` | Payment Success/Failure |
| `/payments/webhook` | POST | *N/A — server only* | — |
| `/admin/admin-login` | POST | `AdminAuthBloc` | Admin Login |
| `/admin/create-admin` | POST | `AdminManagementBloc` | Admin Management |
| `/admin/block-admin` | POST | `AdminManagementBloc` | Admin Management |
| `/admin/unblock-admin` | POST | `AdminManagementBloc` | Admin Management |
| `/admin/get-all-admins` | GET | `AdminManagementBloc` | Admin Management |
| `/admin/logout` | POST | `AdminAuthBloc` | Admin Settings |
| `/admin/recharges` | GET | `AdminRechargesBloc` | Recharge Transactions |
| `/admin/recharges/:transactionId` | GET | `AdminRechargesBloc` | Recharge Detail |

---

## 9. Testing Strategy

| Layer | Approach |
|---|---|
| Bloc | `bloc_test` — verify state emission sequences per event, including error paths and token-refresh-triggered retries |
| Repository/DataSource | `mocktail` for Dio, verify correct endpoint, headers (`Authorization`, `withCredentials`), and payload shape |
| Widget | `flutter_test` golden/widget tests for form validation (profile, admin create), status chips, empty states |
| Integration | `integration_test` for full Auth → Profile → Plan → Payment happy path against a staging environment |

---

## 10. Open Questions for Engineering / Product Alignment

1. Does `newBalance` in the payment-verify response account for `bonusPoints`, or is bonus credited via a separate ledger entry reflected only in recharge-history? (Affects success-screen copy.)
2. What is the exact rate-limit window/retry-after value for `/auth/send-otp` `429` responses, so the client can render an accurate countdown rather than a generic one?
3. Should the Admin module ship as a separate app flavor/build target, or as a role-gated section within the single consumer app binary?
4. Are there webhook-driven push notifications (e.g., wallet credited) planned, which would require FCM integration in this app, separate from the polling-based `/payments/verify` flow?

---

*End of Document*