 🌿 MINT TALK
Flutter App — Product Requirements Document
AI Agent Integration Guide  ·  v1.0  ·  March 2026


Document Type	Product Requirements Document (PRD)
App Name	Mint Talk
Platform	Flutter (iOS & Android)
Backend	https://mint-talk-backend.onrender.com/api/v1
State Management	BLoC / Cubit
Architecture	Clean Architecture
HTTP Client	http package
Version	1.0.0
Status	Ready for Development
Last Updated	March 2026


📋  HOW TO USE THIS PRD (for AI Agents)

This document is structured as an agent-readable specification. Each section maps directly to a
Flutter implementation task. Follow the folder structure, naming conventions, and code patterns
exactly as described. Do not deviate from Clean Architecture layers or BLoC conventions.
All API endpoints are mapped to specific use cases and cubits/blocs.

 
SECTION 1  ·  Project Overview & Goals

1. Project Overview
Mint Talk is a consumer-facing mobile application built with Flutter. It enables users to register via phone OTP, manage a digital wallet of points, purchase plans via Razorpay, and access admin features for privileged roles. The app must be production-grade, maintainable, and scalable.

1.1  Core Objectives
•	Implement full OTP-based authentication flow (send → verify → profile)
•	Wallet management: initialize, view balance, view history
•	Plan browsing and purchase via Razorpay payment gateway
•	Admin panel: manage admins, view recharges, credit/debit wallets
•	Token lifecycle: auto-refresh on 401/403, secure cookie handling
•	Maintain strict Clean Architecture with BLoC/Cubit state management

1.2  Tech Stack
Layer	Technology	Purpose
UI	Flutter 3.x	Cross-platform UI
State	BLoC / Cubit	Reactive state management
HTTP	http package	API communication
DI	get_it + injectable	Dependency injection
Storage	flutter_secure_storage	Token & secure data
Routing	go_router	Declarative navigation
Env	.env / flutter_dotenv	Environment config
Models	json_serializable	JSON serialization
Payments	razorpay_flutter	Razorpay SDK

 
SECTION 2  ·  Clean Architecture Folder Structure

2. Folder Structure
Every AI agent MUST follow this exact folder structure.  
 
SECTION 3  ·  Core Infrastructure

3. Core Infrastructure
3.1  API Client (core/network/api_client.dart)
This is the single HTTP client used by ALL remote data sources. It must:
•	Always include withCredentials equivalent (cookie support via http)
•	Attach Authorization: Bearer <accessToken> on every protected request
•	On 401/403 response: auto-call refresh token, update token, retry ONCE
•	On refresh failure: clear tokens, emit unauthenticated event, redirect to login
•	Support both JSON response formats: { success } and { status }

CRITICAL: The http package does NOT handle cookies automatically.
Use the cookie_jar + dio OR manually extract and send the refreshToken cookie.
Recommended: use http package with a custom CookieManager wrapper.
Store refreshToken in flutter_secure_storage keyed as 'refresh_token'.
Store accessToken in memory (not persisted) — re-fetch on app start via refresh endpoint.

3.2  Token Manager (core/utils/token_manager.dart)
•	saveAccessToken(String token) — in-memory only
•	getAccessToken() → String?
•	saveRefreshToken(String token) — flutter_secure_storage
•	getRefreshToken() → Future<String?>
•	clearAll() — called on logout

3.3  Failures & Exceptions (core/errors/)
Use Failure sealed classes (not raw exceptions) to propagate errors across layers:
•	ServerFailure(message, statusCode)
•	NetworkFailure(message)
•	UnauthorizedFailure()  — triggers logout flow
•	ValidationFailure(message)
•	RateLimitFailure()  — 429 errors

3.4  Environment Config (core/constants/api_endpoints.dart)
static const String baseUrl = 'https://mint-talk-backend.onrender.com/api/v1';
static const String health   = '/health';   // Note: outside /api/v1
// Auth
static const String sendOtp      = '/auth/send-otp';
static const String verifyOtp    = '/auth/verify-otp';
static const String refreshToken = '/auth/refresh-token';
static const String logout       = '/auth/logout';
// User
static const String updateProfile   = '/user/profile';
static const String referralVerify  = '/user/referral-verify';
// Plans, Wallet, Payments, Admin — define all endpoint constants here

 
SECTION 4  ·  Feature Specifications

4. Feature Specifications
4.1  Authentication Feature
Use Cases
Use Case Class	Method	API Endpoint
SendOtp	call(phone, countryCode)	POST /auth/send-otp
VerifyOtp	call(phone, countryCode, otp)	POST /auth/verify-otp
RefreshToken	call()	POST /auth/refresh-token
Logout	call()	POST /auth/logout

AuthCubit States
•	AuthInitial
•	AuthLoading
•	OtpSent  — navigate to OTP verify page
•	AuthAuthenticated(UserEntity user, String accessToken)  — navigate to home/profile
•	AuthProfileIncomplete  — user.profileCompleted == false, navigate to profile page
•	AuthError(String message)
•	AuthRateLimited  — 429 response, show cooldown UI

Request/Response Contract
POST /auth/send-otp  body: { phone, countryCode }
POST /auth/verify-otp  body: { phone, countryCode, otp }  → sets HTTP-only refreshToken cookie
  Response: { success, message, user: { _id, phone, role, profileCompleted }, accessToken }
POST /auth/refresh-token  → requires refreshToken cookie  → returns { success, accessToken }
POST /auth/logout  → clears session  → clear all local tokens

4.2  User / Profile Feature
Use Cases
Use Case	Method	API Endpoint
UpdateProfile	call(ProfileParams)	PATCH /user/profile
VerifyReferral	call(String code)	GET /user/referral-verify

ProfileCubit States
•	ProfileInitial, ProfileLoading
•	ProfileUpdated(UserEntity)  — navigate to home
•	ProfileError(String message)

Validation Rules (enforce on client before API call)
•	fullName: 5–50 chars
•	dob: valid date, user age >= 18
•	gender: one of male | female | other
•	referralCode: optional, uppercase alphanumeric/hyphen, 4–15 chars
•	termsAcceptedAt: valid ISO 8601 datetime

4.3  Plans Feature
Use Cases
Use Case	Returns	API Endpoint
GetPlans	List<PlanEntity>	GET /plans
GetPlanById	PlanEntity	GET /plans/:planId

PlansCubit States
•	PlansInitial, PlansLoading
•	PlansLoaded(List<PlanEntity> plans)
•	PlanDetailLoaded(PlanEntity plan)
•	PlansError(String message)

PlanEntity fields
•	id, name, price, country, currency, points, bonusPoints, isActive, createdAt

4.4  Wallet Feature
Use Cases
Use Case	Auth Required	API Endpoint
InitializeWallet	Bearer	POST /wallet/initialize
GetWalletBalance	Bearer	GET /wallet/:userId/balance
GetRechargeHistory	Bearer	GET /wallet/:userId/recharge-history
GetReferralStatus	Bearer	GET /wallet/:userId/referral-status

WalletCubit States
•	WalletInitial, WalletLoading
•	WalletLoaded(WalletEntity wallet)
•	RechargeHistoryLoaded(List<RechargeEntity>)
•	ReferralStatusLoaded(ReferralEntity? referral)  — nullable, null means no referral
•	WalletError(String message)

IMPORTANT — Wallet Response Format:
Wallet APIs return { status: 'success', data: { ... } }  (NOT { success: true }).
The API client must handle BOTH formats. Check for both 'success' bool and 'status' string.

4.5  Payments Feature (Razorpay)
Payment Flow (strict sequence)
1.	User selects a plan → call CreateOrder use case
2.	Backend returns orderId, amount, currency, key
3.	Open Razorpay checkout with returned key and orderId
4.	On success: Razorpay returns razorpay_order_id, razorpay_payment_id, razorpay_signature
5.	Call VerifyPayment use case with all 4 fields + transactionId
6.	On verified: show success, refresh wallet balance
7.	Handle 'Payment already processed' gracefully — refresh balance, show info

PaymentCubit States
•	PaymentInitial, PaymentLoading
•	OrderCreated(OrderEntity)  — open Razorpay SDK
•	PaymentVerified(int newBalance)  — wallet credited
•	PaymentAlreadyProcessed(int newBalance)
•	PaymentError(String message)

DO NOT call POST /payments/webhook from the Flutter app.
This endpoint is Razorpay server-to-server only. Never expose or call it from client.

4.6  Admin Feature
Admin Use Cases
Use Case	Role Required	API Endpoint
AdminLogin	none	POST /admin/admin-login
CreateAdmin	super_admin	POST /admin/create-admin
BlockAdmin	super_admin	POST /admin/block-admin
UnblockAdmin	super_admin	POST /admin/unblock-admin
GetAllAdmins	super_admin	GET /admin/get-all-admins
AdminLogout	admin|super_admin	POST /admin/logout
GetRecharges	admin|super_admin	GET /admin/recharges
GetRechargeById	admin|super_admin	GET /admin/recharges/:id

Admin-specific Notes
•	Admin login returns access token in the RESPONSE HEADER (Authorization: Bearer <token>), NOT in body.
•	Extract token from response.headers['authorization'] and strip 'Bearer ' prefix.
•	AdminCubit is separate from AuthCubit — maintain separate state trees.
•	GET /admin/recharges supports query params: status, userId, page, limit (max 100).
•	Paginate recharges list using page/limit; store pagination metadata in state.

 
SECTION 5  ·  BLoC / Cubit Conventions

5. BLoC / Cubit Conventions
All AI agents MUST follow these conventions for every feature cubit.

5.1  Cubit Naming
Feature	Cubit Class	State Class
Auth	AuthCubit	AuthState
User Profile	ProfileCubit	ProfileState
Plans	PlansCubit	PlansState
Wallet	WalletCubit	WalletState
Payments	PaymentCubit	PaymentState
Admin	AdminCubit	AdminState

5.2  State Pattern
Use sealed classes (Dart 3+) or abstract classes with subclasses. Every state must be immutable.
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class OtpSent extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  final String accessToken;
  const AuthAuthenticated({ required this.user, required this.accessToken });
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

5.3  Cubit Method Pattern
Every cubit method must: emit Loading, call use case, handle Either<Failure, T>, emit success or error.
Future<void> sendOtp(String phone, String countryCode) async {
  emit(AuthLoading());
  final result = await _sendOtp(SendOtpParams(phone: phone, countryCode: countryCode));
  result.fold(
    (failure) => emit(AuthError(failure.message)),
    (_) => emit(OtpSent()),
  );
}

5.4  Use Case Pattern
All use cases extend UseCase<Type, Params> and return Either<Failure, Type>.
class SendOtp implements UseCase<void, SendOtpParams> {
  final AuthRepository repository;
  SendOtp(this.repository);
  @override
  Future<Either<Failure, void>> call(SendOtpParams params) =>
    repository.sendOtp(params.phone, params.countryCode);
}

 
SECTION 6  ·  Error Handling Strategy

6. Error Handling
6.1  HTTP Status Code Handling
Status Code	Action	Failure Type
200 / 201	Parse response	—
400	Show validation message	ValidationFailure
401	Auto-refresh token → retry once → else logout	UnauthorizedFailure
403	Auto-refresh → retry once → else navigate to login	UnauthorizedFailure
404	Show 'not found' message	ServerFailure
429	Show rate limit UI, implement backoff	RateLimitFailure
500+	Show generic error, retry with backoff	ServerFailure

6.2  Token Refresh Interceptor Logic
8.	Make API request with current accessToken.
9.	If response is 401 or 403:
10.	Call POST /auth/refresh-token (uses refreshToken cookie).
11.	If refresh succeeds: save new accessToken, retry original request once.
12.	If refresh fails (403): call clearAll() on TokenManager, emit UnauthorizedFailure.
13.	Navigation layer listens for UnauthorizedFailure and redirects to OTP login.

6.3  Response Format Normalisation
The API returns two formats. The API client must normalize before returning:
Format 1: { "success": true/false, ... }
Format 2: { "status": "success" | "error", ... }

Normalise logic:
  bool isSuccess = body['success'] == true || body['status'] == 'success';
  if (!isSuccess) throw ServerException(body['message'] ?? 'Unknown error');

6.4  Retry with Exponential Backoff (429 / 500)
•	On 429: wait 2s, 4s, 8s before retrying (max 3 retries).
•	On 500: wait 1s, 2s, 4s before retrying (max 2 retries).
•	Show appropriate UI feedback during retry (e.g., 'Retrying...').

 
SECTION 7  ·  Navigation & Routing

7. Navigation (go_router)
7.1  Route Definitions
Route Path	Page	Guard
/	SplashPage	Check token → redirect
/otp-send	OtpSendPage	Public
/otp-verify	OtpVerifyPage	After OTP sent
/profile-setup	ProfileSetupPage	Authenticated, profile incomplete
/home	HomePage	Authenticated
/wallet	WalletPage	Authenticated
/plans	PlansPage	Authenticated
/payment/:planId	PaymentPage	Authenticated
/admin/login	AdminLoginPage	Public
/admin/dashboard	AdminDashboardPage	Admin role
/admin/recharges	AdminRechargesPage	Admin role

7.2  Auth Guards
•	On app start: check refreshToken in secure storage.
•	If token exists: call /auth/refresh-token → if success, go to /home; else go to /otp-send.
•	If profileCompleted == false after authentication: redirect to /profile-setup.
•	Admin routes guarded by role check (role == 'admin' || role == 'super_admin').

 
SECTION 8  ·  Data Models & Entities

8. Data Models & Entities
8.1  Entity Definitions
Entities live in domain/entities/ and have NO dependency on any framework or data layer.

Entity	Key Fields	Feature
UserEntity	id, phone, role, profileCompleted, fullName?, gender?, dob?	auth / user
PlanEntity	id, name, price, country, currency, points, bonusPoints, isActive	plans
WalletEntity	id, userId, balance, status	wallet
RechargeEntity	transactionId, amount, currency, points, status, createdAt	wallet
ReferralEntity	id, referrerRewardPoints, status, transaction, rewardedAt	wallet
OrderEntity	orderId, amount, currency, planName, pointsToCredit, transactionId, key	payments
AdminEntity	id, fullName, email, role, accessLevel, isBlocked	admin

8.2  Model (Data Layer) Rules
•	Models extend their Entity and add fromJson / toJson methods.
•	Use json_serializable with @JsonSerializable() annotation.
•	Never pass raw Map<String, dynamic> between layers — always parse to model/entity.

 
SECTION 9  ·  Dependency Injection

9. Dependency Injection (get_it)
All classes must be registered in core/di/injection_container.dart. Use factory for use cases and singletons for repositories and the API client.

final sl = GetIt.instance;

void init() {
  // Core
  sl.registerLazySingleton(() => ApiClient(tokenManager: sl()));
  sl.registerLazySingleton(() => TokenManager());

  // Auth
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerFactory(() => SendOtp(sl()));
  sl.registerFactory(() => VerifyOtp(sl()));
  sl.registerFactory(() => AuthCubit(sendOtp: sl(), verifyOtp: sl(), logout: sl()));

  // Repeat pattern for: user, plans, wallet, payments, admin
}

 
SECTION 10  ·  Security & Cookie Handling

10. Security Requirements
10.1  Token Storage
Token	Storage	Notes
accessToken	In-memory (variable)	Never persisted to disk
refreshToken	flutter_secure_storage	Key: 'refresh_token'
Admin accessToken	In-memory	Extracted from response header

10.2  Cookie Handling (refreshToken)
The http package does not automatically manage cookies. Implement the following:
•	On verify-otp response: extract Set-Cookie header, parse refreshToken value, store in flutter_secure_storage.
•	On every subsequent request that needs cookie: add Cookie: refreshToken=<value> header manually.
•	On logout: clear secure storage and remove cookie header.

ALTERNATIVE APPROACH: Use the dio package with dio_cookie_manager + cookie_jar
for automatic cookie persistence. If using dio, replace the http ApiClient entirely.
Both approaches are acceptable — pick one and be consistent throughout the project.
Document your choice in the project README.

10.3  withCredentials Equivalent
Flutter's http package does not have a withCredentials flag like browsers. The equivalent is manually managing the Cookie header as described above. This is mandatory for the refresh token flow to work.

 
SECTION 11  ·  API Endpoints Master Reference

11. Full API Reference
Base URL: https://mint-talk-backend.onrender.com/api/v1
Health: https://mint-talk-backend.onrender.com/health  (note: outside /api/v1)

Method	Endpoint	Auth
GET	/health	None
POST	/auth/send-otp	None
POST	/auth/verify-otp	None
POST	/auth/refresh-token	Cookie
POST	/auth/logout	Cookie
PATCH	/user/profile	Bearer
GET	/user/referral-verify?referralCode=X	Bearer
GET	/plans	Public
GET	/plans/:planId	Public
POST	/plans	admin | super_admin
PATCH	/plans/:planId	admin | super_admin
DELETE	/plans/:planId	admin | super_admin
POST	/wallet/initialize	Bearer
GET	/wallet/:userId/balance	Bearer
POST	/wallet/credit	admin | super_admin
POST	/wallet/debit	admin | super_admin
GET	/wallet/:userId/recharge-history	Bearer
GET	/wallet/:userId/referral-status	Bearer
POST	/payments/create-order	Bearer
POST	/payments/verify	Bearer
POST	/payments/webhook	SERVER ONLY
POST	/admin/admin-login	None
POST	/admin/create-admin	super_admin
POST	/admin/block-admin	super_admin
POST	/admin/unblock-admin	super_admin
GET	/admin/get-all-admins	super_admin
POST	/admin/logout	admin | super_admin
GET	/admin/recharges	admin | super_admin
GET	/admin/recharges/:transactionId	admin | super_admin

 
SECTION 12  ·  AI Agent Implementation Checklist

12. Implementation Checklist for AI Agents
Use this checklist to track implementation progress. Each item maps to a concrete deliverable.

Phase 1 — Core Infrastructure
•	[ ]  Create folder structure as defined in Section 2
•	[ ]  Implement ApiClient with token injection and auto-refresh
•	[ ]  Implement TokenManager with secure storage
•	[ ]  Define all Failure types in core/errors/failures.dart
•	[ ]  Define all API endpoint constants in api_endpoints.dart
•	[ ]  Setup get_it injection container with all registrations
•	[ ]  Configure go_router with all routes and auth guards

Phase 2 — Authentication Feature
•	[ ]  AuthRemoteDataSource: sendOtp, verifyOtp, refreshToken, logout
•	[ ]  AuthRepositoryImpl
•	[ ]  Use cases: SendOtp, VerifyOtp, RefreshToken, Logout
•	[ ]  AuthCubit with all states
•	[ ]  OtpSendPage, OtpVerifyPage UI
•	[ ]  Cookie extraction from verify-otp response headers

Phase 3 — User Profile
•	[ ]  UserRemoteDataSource: updateProfile, verifyReferral
•	[ ]  ProfileCubit with client-side validation
•	[ ]  ProfileSetupPage with form and validation UI

Phase 4 — Plans & Wallet
•	[ ]  PlansRemoteDataSource, PlansCubit, PlansPage, PlanDetailPage
•	[ ]  WalletRemoteDataSource, WalletCubit
•	[ ]  WalletPage: balance, recharge history, referral status

Phase 5 — Payments
•	[ ]  PaymentRemoteDataSource: createOrder, verifyPayment
•	[ ]  PaymentCubit with full Razorpay SDK integration
•	[ ]  Handle success, already-processed, and failure flows

Phase 6 — Admin Panel
•	[ ]  AdminRemoteDataSource (all admin endpoints)
•	[ ]  AdminCubit
•	[ ]  AdminLoginPage, AdminDashboardPage, AdminRechargesPage
•	[ ]  Extract token from response header on admin login
•	[ ]  Role-based UI guards (super_admin vs admin)

Phase 7 — Polish & QA
•	[ ]  Unit tests for all use cases
•	[ ]  Widget tests for critical pages
•	[ ]  Error boundary widgets for all pages
•	[ ]  Exponential backoff for 429/500 errors
•	[ ]  Token refresh integration test

FINAL REMINDER TO AI AGENTS:

1.  Never skip the Clean Architecture layer boundaries.
2.  Never call API endpoints directly from UI widgets.
3.  Always go: Widget → Cubit → UseCase → Repository → DataSource → ApiClient.
4.  Always handle BOTH API response formats ({ success } and { status }).
5.  Never call /payments/webhook from the Flutter app.
6.  Admin login token is in the RESPONSE HEADER, not the body.
7.  refreshToken is an HTTP-only cookie — handle manually in Flutter.
8.  Use Either<Failure, T> return types across all repository and use case calls.


— End of Document —
Mint Talk Flutter PRD v1.0  ·  Confidential  ·  March 2026
