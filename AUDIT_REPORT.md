# Mint-Talk — Security, Performance & Scalability Audit

**Scope:** Read-only diagnostic audit of the Flutter client (Clean Architecture, Bloc/Cubit, get_it+injectable, Dio, socket_io_client, agora_rtc_engine). No application or UI/UX code was modified as part of this pass — findings and recommended fixes only.

**Severity legend:** Critical (exploitable now, high impact) · High (real defect, should be scheduled soon) · Medium (real risk, moderate impact) · Low (hardening/hygiene) · Informational (note/dependency, no action required in this repo)

---

## 1. Screenshot & Screen-Recording Protection

| # | Finding | Location | Severity |
|---|---|---|---|
| 1.1 | `screen_protector` (`preventScreenshotOn()`) is applied once, globally, at app boot — never toggled off. This sets `FLAG_SECURE` (Android) / `ScreenProtectorKit` (iOS) for the whole app lifetime. | `lib/main.dart:20` | Low |
| 1.2 | No jailbreak/root detection anywhere in the repo (`flutter_jailbreak_detection`, `safe_device`, etc. all absent). | n/a | Low |
| 1.3 | No `AppLifecycleState`/`WidgetsBindingObserver` handling anywhere in `lib/` — no blur/placeholder overlay when the app backgrounds. Call video, OTP entry, and wallet amounts can appear in the OS app-switcher thumbnail. Partially mitigated by 1.1 (`FLAG_SECURE` also suppresses the Android recents thumbnail), but no equivalent explicit safeguard exists, and iOS still has no blur-on-inactive. | n/a | Medium |
| 1.4 | `android:allowBackup` is not set in the manifest, so it defaults to `true` — app data (including anything outside `flutter_secure_storage`'s Keystore-backed scope) is eligible for `adb backup`/cloud backup. | `android/app/src/main/AndroidManifest.xml` | Low |

**Why it matters:** Sensitive screens (calls, OTP, wallet/withdrawal) are the exact class of screen this protection exists for. The global toggle is *directionally* correct (safe default), but there's no code path reacting to backgrounding, so a device screenshot check alone doesn't cover app-switcher leakage or third-party device management tooling that can bypass `FLAG_SECURE` on some OEMs.

**Recommended fixes (no UI/UX change):**
- Add `android:allowBackup="false"` (and `android:fullBackupContent="@xml/backup_rules"` if selective backup is ever needed) to the `<application>` tag.
- Add a `WidgetsBindingObserver`-based service (e.g. `lib/core/services/app_lifecycle/secure_lifecycle_service.dart`) that pushes a blur overlay via `Navigator`'s root overlay on `AppLifecycleState.inactive`/`paused` and removes it on `resumed` — this is additive (a new overlay route), not a change to any existing screen's layout or behavior.
- Note `flutter_jailbreak_detection` as an optional future dependency decision — not added in this pass since it requires a product decision on response behavior (block vs. warn vs. degrade).

---

## 2. Authentication & Session Security

| # | Finding | Location | Severity |
|---|---|---|---|
| 2.1 | Access token held in-memory only (`TokenManager._accessToken`); refresh token + PII persisted via `flutter_secure_storage` (Keychain/Keystore-backed). No `shared_preferences`/Hive/plaintext storage of tokens found anywhere. | `lib/core/utils/token_manager.dart:11-19`, `lib/features/auth/data/datasources/auth_local_data_source.dart:8-27` | — (clean) |
| 2.2 | Refresh interceptor correctly bounds retries: a `requestOptions.extra['isRetry']` flag prevents infinite 401→refresh→401 loops. On refresh failure, tokens are cleared and the user is force-navigated to login. | `lib/core/network/interceptors/auth_interceptor.dart:43-95` | — (clean) |
| 2.3 | No single-flight guard around concurrent 401s — multiple in-flight requests can each independently trigger a refresh call. Not a security bug, just redundant backend calls. | `lib/core/network/interceptors/auth_interceptor.dart:97-135`, `lib/core/utils/token_manager.dart:67-105` | Low |
| 2.4 | The refresh token (originally an `HttpOnly` `Set-Cookie` from the backend) is manually pulled out of secure storage and re-attached as a `Cookie` header on every outgoing request. This defeats the purpose of `HttpOnly` and puts the refresh token into Dio's in-memory headers and the same interceptor/logging pipeline as everything else. | `lib/core/network/interceptors/auth_interceptor.dart:29-32` | Medium |
| 2.5 | No biometric gate (`local_auth` not a dependency) for app re-entry or sensitive actions like wallet withdrawal. | n/a | Low |
| 2.6 | No OTP logging found (good). No client-side lockout on repeated wrong-OTP submissions — `submitOtp` auto-fires on every 4th digit with no local attempt cap. Only the *resend* action has a (server-driven) cooldown. | `lib/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart:87-90,147-223` | Medium |

**Recommended fixes:**
- 2.4: Stop manually building the `Cookie` header in `AuthInterceptor`; let Dio's cookie jar (or the platform's native cookie handling) manage the `HttpOnly` cookie automatically, and only manually attach the `Authorization: Bearer` header.
- 2.6: Add a local failed-attempt counter to `OtpVerificationState`/`OtpVerificationCubit` that disables further auto-submit after N (e.g. 5) consecutive failures until resend, purely additive state — no screen layout change required.
- 2.5: Note as optional hardening; requires a product decision on which actions to gate, out of scope for this pass.

---

## 3. API Security (Dio)

| # | Finding | Location | Severity |
|---|---|---|---|
| 3.1 | Base URL is HTTPS in all three flavors (dev/staging/prod); no hardcoded `http://` found. | `lib/config/env/env_config.dart:18-19,42-44,67-68` | — (clean) |
| 3.2 | **No certificate pinning** — no `HttpClientAdapter`/`badCertificateCallback`/pinning package anywhere. All Dio and socket.io traffic trusts the OS/device trust store only. | n/a | Medium-High |
| 3.3 | Custom `LoggerInterceptor` is properly gated by `kDebugMode` for request/response/error logs. No `PrettyDioLogger`/built-in `LogInterceptor` found. | `lib/core/network/interceptors/logger_interceptor.dart:19,29,38` | — (clean) |
| 3.4 | Other `Logger()`/`appLogger` instances (outside the Dio interceptor) are *not* explicitly gated by `kReleaseMode` — they rely on the `logger` package's own release-suppressed default filter, which is an implicit rather than explicit guard. | `lib/core/utils/app_logger.dart:3-11`, `lib/core/services/agora/agora_service.dart:10`, `lib/core/services/socket/presence_socket_service.dart:42` | Low |
| 3.5 | Widespread `catch (e) { return Left(ServerFailure(message: e.toString())) }` fallback across ~20 repository implementations surfaces raw Dart runtime exception strings (type names, null-safety errors) directly into Cubit/Bloc error state shown to the user. | e.g. `lib/features/auth/data/repositories/auth_repository_impl.dart:43-44`, `lib/features/user_side/call/data/repositories/call_repository_impl.dart:59,71,83,...`, and ~15 more repository impls following the same pattern | Low |
| 3.6 | No `sendTimeout` configured on the shared Dio client (only `connectTimeout`/`receiveTimeout` are set) — large uploads (e.g. multipart) can hang indefinitely. | `lib/core/network/dio_provider.dart:12-31` | Low |
| 3.7 | No client-side IDOR: the client never self-asserts a user identity via a spoofable field — resource ownership is implicit via the bearer token, and endpoints that take a `callId`/`hostId` rely on server-side ownership checks (outside this repo's visibility). | `lib/features/user_side/call/data/datasources/call_remote_data_source.dart:36-80`, `lib/features/host_side/host_wallet/data/datasources/host_wallet_remote_datasource.dart:26-49` | Informational (backend dependency) |

**Recommended fixes:**
- 3.2: Add certificate pinning to the shared `Dio` instance in `dio_provider.dart`, scoped to release builds (e.g. via a `HttpClientAdapter` configured with the backend's pinned public key/cert hash), leaving debug builds unpinned for local development against staging.
- 3.5: Add a `mapExceptionToFailure(Object e)` helper in `lib/core/error/` that repositories call in their generic catch blocks — returns a generic `ServerFailure(message: 'Something went wrong, please try again.')` for unrecognized exceptions while still logging `e` internally via `appLogger`. This is a pure data/domain-layer change; no UI copy or behavior changes beyond replacing today's raw exception string with a friendlier generic one.
- 3.6: Add `sendTimeout` to `BaseOptions` in `dio_provider.dart`, matching the existing `connectTimeout`/`receiveTimeout` values.
- 3.4: Wrap the sensitive log call sites listed in §6 with explicit `if (kDebugMode)` for defense-in-depth rather than relying solely on the package default.

---

## 4. Socket (Real-time) Security

| # | Finding | Location | Severity |
|---|---|---|---|
| 4.1 | Connection is authenticated over WSS with the access token sent redundantly three ways: `auth.token`, `auth.auth`, and an `Authorization` header. Not a vulnerability, but unnecessary duplication across the wire/logs. | `lib/core/services/socket/presence_socket_service.dart:112-127` | Low |
| 4.2 | `PresenceSocketService` is correctly registered as a `@LazySingleton` — one socket instance app-wide, confirmed in DI config. | `lib/core/di/injection.config.dart:370-371` | — (clean) |
| 4.3 | No `socket.off()` calls anywhere in the codebase (13 `.on()` registrations, 0 `.off()`). Mitigated because every reconnect path fully `dispose()`s and recreates the socket before re-registering listeners, so duplication on a single socket object doesn't occur — but cleanup relies entirely on full teardown rather than selective removal. | `lib/core/services/socket/presence_socket_service.dart:97-130,227-476` | Low |
| 4.4 | `PresenceSocketService.dispose()` (full teardown including stream controllers) is never called by any consumer — acceptable for an app-lifetime singleton, but there is no explicit disconnect/reconnect-with-new-token step wired into the normal (non-forced) logout path, only into forced-session-termination and "Go Offline" paths. If a user logs out and a different user logs in without an app restart, a window exists where the socket isn't proactively cycled to the new identity until the next explicit `connect(token)` call. | `lib/core/services/socket/presence_socket_service.dart:198-208`, compare `host_dash_cubit.dart:251,279` and `presence_socket_service.dart:392,451` | Medium |
| 4.5 | Reconnection uses exponential backoff with jitter (`reconnectionDelay`, `reconnectionDelayMax`, `randomizationFactor`) — no storm risk found. `connectivity_plus` changes only drive a UI banner, not forced reconnects. | `lib/core/services/socket/presence_socket_service.dart:120-125`, `lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:565-584` | — (clean) |
| 4.6 | `onAny` wildcard logs every raw server event payload unconditionally (not gated by `kDebugMode`) — could include call/session data in logs. | `lib/core/services/socket/presence_socket_service.dart:230-236` | Low |

**Recommended fixes:**
- 4.4: In `AuthRepositoryImpl.logout()` (`lib/features/auth/data/repositories/auth_repository_impl.dart`), explicitly call the socket service's disconnect (and reconnect on next login) so no stale-identity socket window exists across a same-session user switch.
- 4.1/4.6: Consolidate to a single auth field in the socket connection options; gate the `onAny` debug log behind `kDebugMode` to match the pattern already used in `LoggerInterceptor`.
- 4.3: Add explicit `.off()` calls immediately before each `dispose()`/socket-recreate point, as a hygiene improvement even though no active leak was found.

---

## 5. Agora (Voice/Video Call) Security

| # | Finding | Location | Severity |
|---|---|---|---|
| 5.1 | **Agora App Certificate is hardcoded in `.env.dev`, which is tracked in git and bundled as a Flutter asset.** Verified directly: `git ls-files` shows `.env.dev`/`.env.staging`/`.env.prod` are all tracked; `git show HEAD:.env.dev` contains `AGORA_APP_ID=49768f1fb6874d77af331da0b3cb76a0` and `AGORA_APP_CERTIFICATE=340bc88b64ff4679884133997f122cd3`. `pubspec.yaml:69-73` lists all four `.env*` files as assets, so whichever is loaded ships inside the compiled APK/IPA. `lib/main.dart:12` defaults `ENV` to `'dev'` via `String.fromEnvironment`, so **any build without an explicit `--dart-define=ENV=prod` loads `.env.dev` and its real certificate.** The certificate is also present in git history (commits `182efe3`, `00b3b1f`), independent of the current working tree. The client code never actually reads `AGORA_APP_CERTIFICATE` (`AgoraConfig` only uses `appId`) — it's unused, shipped, exposed dead data. | `.env.dev` (repo root), `pubspec.yaml:69-73`, `lib/main.dart:11-15` | **Critical** |
| 5.2 | RTC tokens are fetched from the backend per call session (via `/calls/*` responses), never generated or hardcoded client-side. `onTokenPrivilegeWillExpire` is correctly wired to fetch a fresh token and call `renewToken()` without dropping the call. | `lib/core/services/agora/agora_service.dart:111-114,132-136`; `lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:509-511,604-620` | — (clean) |
| 5.3 | Channel names are always server-issued and read from the API response (`agoraChannel`/`channelName`) — the client never constructs a channel name, so there's no client-side guessability/brute-force surface. | `lib/features/user_side/call/data/models/call_session_dto.dart:39-42`, `incoming_call_payload_dto.dart:40` | — (clean) |
| 5.4 | `leaveChannel()`/`release()` are called on every call-end path and on `CallScreenCubit.close()` — no orphaned engine instances found. | `lib/core/services/agora/agora_service.dart:207-219,279-294`; `lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:395,436,592,662,914,932,1003-1011` | — (clean) |
| 5.5 | The raw, unredacted RTC token is logged at info level, mislabeled as "Sanitized" — the `_sanitizeToken()` helper only trims whitespace/normalizes null-like strings, it does not mask the token. | `lib/core/services/agora/agora_service.dart:161-165,198-204,225` | Medium |
| 5.6 | Mic/camera permission requests are real (`permission_handler`), and call UI state correctly branches on actual grant/denial/permanent-denial rather than assuming success. | `lib/core/services/permissions/call_permission_service.dart:34,50`; `call_screen_cubit.dart:213-228` | — (clean) |

**Why 5.1 matters:** The App Certificate is meant to be a server-only secret used to *sign* RTC tokens. Anyone who extracts it — by unzipping the shipped app bundle or reading git history — can mint valid tokens for **any** channel name and UID without going through the backend's `/calls/*` authorization at all, allowing them to join, eavesdrop on, or hijack arbitrary active call sessions.

**Recommended fixes:**
- 5.1 (do first, independent of everything else in this report):
  1. Remove `AGORA_APP_CERTIFICATE` entirely from `.env`, `.env.dev`, and any other tracked env file — it's not read anywhere in `lib/`, so removing it is a no-op for app behavior.
  2. `git rm --cached .env.dev` (and `.env.staging`/`.env.prod` if they ever carry real values) and add them to `.gitignore`; commit a `.env.example` with placeholder keys instead, matching what `.env.staging`/`.env.prod` already do for `AGORA_APP_ID`.
  3. Purge the certificate from git history (e.g. `git filter-repo`) — a separate, explicitly-approved step since it rewrites history and affects all clones/forks.
  4. Rotate the exposed App Certificate on the Agora console, since it must be treated as already compromised.
- 5.5: Fix `_sanitizeToken()` (or the call site) to actually redact the token (e.g. log only its length/first 6 chars) and wrap the log call in `if (kDebugMode)`.

---

## 6. Data Storage & Privacy (local, on-device)

| # | Finding | Location | Severity |
|---|---|---|---|
| 6.1 | No Hive/sqflite/Isar usage anywhere — no local database of chat/PII data exists to be plaintext or encrypted; the only persistent local store is `flutter_secure_storage` (OS Keychain/Keystore). | n/a (confirmed absent) | — (clean) |
| 6.2 | No `print()`/`debugPrint()` calls anywhere in `lib/` — good baseline hygiene. No Firebase/Crashlytics/Sentry integration exists in the app at all. | n/a | — (clean) |
| 6.3 | Several `appLogger` calls log sensitive payloads without an explicit release gate (relying only on the `logger` package's implicit default filter): Razorpay payment signature and IDs; full raw order-creation response (can include merchant key fields); full payment-verification response including wallet balance data. | `lib/core/services/razorpay_service.dart:54-57`; `lib/features/user_side/wallet/data/models/order_model.dart:17`; `lib/features/user_side/wallet/data/datasources/wallet_remote_datasource.dart:109-111` | Medium |
| 6.4 | `NetworkLogger` (`dart:developer` `log()`) logs full raw request/response bodies **unconditionally**, with no `kDebugMode`/`kReleaseMode` gate at all — but it is dead code, never imported or called anywhere else in the codebase today. | `lib/core/network/network_logger.dart:1-37` | Low (latent only) |

**Recommended fixes:**
- 6.3: Wrap each listed log call in `if (kDebugMode)` and/or redact the sensitive fields (signature, merchant key, balance) before logging, matching the pattern `LoggerInterceptor` already uses.
- 6.4: Either delete `NetworkLogger` (confirmed unused) or add a `kDebugMode` gate to it now, before it's ever wired into `ApiClient`, so it can't become a live leak later without someone noticing the missing guard.

---

## 7. Architecture Review (Clean Architecture layering)

| # | Finding | Location | Severity |
|---|---|---|---|
| 7.1 | 12 presentation Cubits inject the concrete data-layer `AuthLocalDataSource` directly instead of going through the `AuthRepository` domain interface. Root cause: `AuthRepository`'s interface (`sendOtp/verifyOtp/checkIsLoggedIn/...`) doesn't expose the profile-field getters (`getUserId`, `getFullName`, `getFavoriteHostIds`, etc.) these Cubits need, so presentation reaches around the abstraction to get them. | `lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:25`, `user_profile_edit_cubit.dart:20`, `profile_info_cubit.dart:8`, `referral_status_cubit.dart:12`, `apply_for_host_cubit.dart:16`, `user_recharge_history_cubit.dart:14`, `profile_cubit.dart:17`, `call_screen_cubit.dart:50`, `host_profile_edit_cubit.dart:18`, `home_cubit.dart:30`, `host_dash_cubit.dart:23`, `host_profile_cubit.dart:9` — domain gap at `lib/features/auth/domain/repositories/auth_repository.dart:9-35` | High |
| 7.2 | 5 screens/widgets manually instantiate `RepositoryImpl`/`RemoteDataSourceImpl` inside `build()` or event handlers instead of using the already-`getIt`-registered instances — rebuilt on every widget rebuild, bypasses DI and testability entirely. | `lib/features/user_side/recharge_plans/presentation/screen/plan_detail_screen.dart:37-39`; `lib/features/user_side/user_recharge_history/presentation/screen/user_recharge_history.dart:20-23`; `lib/features/user_side/profile_screen/presentation/screen/profile_screen.dart:18`; `lib/features/user_side/profile_screen/presentation/widgets/profile_avatar.dart:179`; `lib/features/user_side/apply_for_host/presentation/screens/terms_and_conditions_for_host.dart:294` | High |
| 7.3 | `HostProfileRemoteDataSourceImpl._cachedProfile` is a mutable `static` field seeded with **hardcoded mock profile data**; `getHostProfile()` never actually calls the network — it just returns this static mock, and `updateHostProfile()` overwrites the static cache with the locally-passed object instead of re-fetching from the server. Being `static`, it's also shared/stale across any user in the same process. | `lib/features/host_side/host_profile_edit/data/datasources/host_profile_remote_datasource.dart:17-26,31-54` | High |
| 7.4 | `CallScreenCubit` is 1012 lines and owns 6+ distinct concerns in one class: call signaling, Agora RTC engine lifecycle, reconnection/resilience (4 separate `Timer` fields), Agora token refresh, socket event handling, billing/activation, and media controls. | `lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart` (full file) | Medium |
| 7.5 | Domain/data split (abstract interface in `domain/repositories/`, impl in `data/repositories/`) is correctly followed in the sampled features (`host_wallet`, `call`, `auth`) — `auth`'s interface is simply incomplete per 7.1, not missing the split itself. | `lib/features/host_side/host_wallet/domain/repositories/host_wallet_repository.dart:5` ↔ `.../data/repositories/host_wallet_repository_impl.dart:12`; similarly for `call` and `auth` | — (clean) |
| 7.6 | DI registration pattern is correct elsewhere: Cubits/Blocs are `factory` (new instance per creation), repositories/datasources are `lazySingleton` and verified stateless (no cached fields) except for 7.3. No other singleton was found holding per-user state that wouldn't reset on logout. | `lib/core/di/injection.config.dart` (spot-checked) | — (clean) |
| 7.7 | No `compute()`/`Isolate.spawn` usage anywhere in the app; no current hot spot was found (sampled DTOs are small/flat), but there's no established pattern to fall back on if host-presence or call-history payload sizes grow. | n/a | Informational (scalability watch-item) |

**Recommended fixes:**
- 7.1: Extend `AuthRepository`'s interface with the read methods the 12 Cubits actually need (delegating to `AuthLocalDataSource` internally, same as today), then update the 12 Cubits' constructors to depend on `AuthRepository` instead of the concrete data source. Domain/data-layer change only, no UI change.
- 7.2: Replace the manual `WalletRepositoryImpl(...)`/`RechargeHistoryRepositoryImpl(...)`/etc. construction in the 5 files with `getIt<WalletRepository>()` / `getIt<RechargeHistoryRepository>()` / the pre-registered `ProfileInfoCubit` factory — these are already wired in `injection.config.dart`, so this is a drop-in replacement with no behavior change.
- 7.3: Remove the static mock field; implement a real `GET` call in `getHostProfile()` mirroring the pattern already used in sibling `*RemoteDataSourceImpl` classes (e.g. `host_wallet_remote_datasource.dart`). This is a functional bug fix (the host profile is currently never actually fetched from the backend), scoped to the data layer.
- 7.4: Split `CallScreenCubit`'s internal responsibilities into 2-3 collaborator classes it delegates to (e.g. `CallReconnectionManager` for the timer/reconnect logic, `CallBillingController` for activation/billing) while keeping its public API/state unchanged — purely an internal refactor, no behavior or UI change.

---

## 8. Performance & Concurrency (target: 50+ concurrent active users)

| # | Finding | Location | Severity |
|---|---|---|---|
| 8.1 | `flutter_screenutil` (`.w/.h/.sp/.r`) is used for nearly all sizing app-wide, and these are runtime (non-const) extension getters — this structurally blocks `const` on the large majority of sized widgets, a systemic/design-level cost rather than a per-file oversight. | app-wide | Informational |
| 8.2 | One concrete missing-`const`: `_BalanceLabel` has no constructor declared (trivially could be `const`), and its call site isn't marked `const`, unlike the sibling `_WalletIconCircle` right above it which does the same pattern correctly. | `lib/features/host_side/host_wallet/presentation/widgets/wallet_balance_card.dart:39,45,83` | Low |
| 8.3 | Synchronous, blocking `File(...).existsSync()` call inside `build()` — runs on every rebuild of the avatar widget. | `lib/features/host_side/host_profile_screen/presentation/widgets/host_profile_avatar.dart:68` | Medium |
| 8.4 | `buildWhen`/`BlocSelector`/`context.select` narrowing is used in only ~28% of the 75 `BlocBuilder`/`BlocConsumer` usages found (`context.select` is never used at all — 0 matches). Several wide-scope builders wrap large subtrees with no narrowing, most notably `CallScreenCubit`'s outer `BlocConsumer` wrapping nearly the entire 613-line in-call UI with no `buildWhen` — meaning the once-per-second duration tick (and any other state field change) rebuilds the whole in-call screen, not just the duration text. Narrower nested builders with `buildWhen` do exist for specific pieces, but they're opt-in additions layered inside the broad outer rebuild, not a replacement for it. | `lib/features/user_side/call/presentation/widgets/call_screen_contents.dart:123` (plus narrower exceptions at `:236-237,416-417,467-468`); also `wallet_contents.dart:19`, `host_call_log_contents.dart:66`, `user_grid.dart:15` | Medium-High (call screen specifically, given the live-UI/concurrency goal) |
| 8.5 | A manually-paginated recharge-history list is rendered via `ListView(children: [...map(...)])` instead of `ListView.builder`/`.separated`, so every currently-loaded item is built/kept alive eagerly rather than lazily per viewport — defeats the point of the pagination as history length grows. | `lib/features/user_side/user_recharge_history/presentation/widgets/user_recharge_history_contents.dart:50` | Medium |
| 8.6 | All other `ListView(` non-builder usages found are bounded/fixed-size UI (settings menu, empty states, skeletons) — not a concern. All data-backed lists elsewhere correctly use `.builder`/`.separated`. | (sampled, multiple files) | — (clean) |
| 8.7 | All 8 `.listen()` stream subscriptions found across the codebase are assigned to a named field and cancelled in the owning Cubit's `close()` or widget's `dispose()` — no leaks found. | `home_cubit.dart`, `call_screen_cubit.dart` (×3), `otp_verification_cubit.dart`, `host_dash_cubit.dart`, `incoming_call_overlay.dart` (×2) | — (clean) |
| 8.8 | No polling pattern found — the only 3 `Timer.periodic` usages are local UI ticks (call duration counter, OTP resend countdown, a cosmetic glow animation), not server status polling. Presence/call-status updates are already event/socket-driven. | `call_screen_cubit.dart:972`, `otp_verification_cubit.dart:213`, `incoming_call_overlay.dart:130` | — (clean) |

**Recommended fixes:**
- 8.4: Add `buildWhen`/`BlocSelector` at the outer `BlocConsumer` level in `call_screen_contents.dart`, splitting the duration-tick-driven region from the rest of the in-call UI so a per-second state emission doesn't rebuild the whole call screen — directly relevant to sustaining smooth call UI performance at higher concurrent-call volume. Apply the same narrowing to `wallet_contents.dart`, `host_call_log_contents.dart`, and `user_grid.dart`.
- 8.5: Replace `ListView(children: [...])` with `ListView.builder`/`.separated` in `user_recharge_history_contents.dart`, keeping the existing scroll-triggered `loadMore()` pagination logic (`:41-47`) as-is — purely a widget construction change, no visual/behavioral difference to the user.
- 8.3: Move the `existsSync()` check out of `build()` — resolve it once in the owning Cubit/state when the avatar path changes, or wrap it in a `FutureBuilder` fed by an async check computed outside the widget tree.
- 8.2: Add `const` to `_BalanceLabel`'s constructor and its call site.

---

## Prioritized Action Plan

### Critical — do first, independently of everything else
1. **5.1** — Remove `AGORA_APP_CERTIFICATE` from all tracked `.env*` files, untrack them from git, add `.env.example`, purge the certificate from git history (separate approved step), and rotate the certificate on the Agora console.

### High — schedule soon
2. **7.3** — Fix `HostProfileRemoteDataSourceImpl`: remove the static mock cache, implement the real network call (currently a functional bug — host profiles are never actually fetched from the backend).
3. **7.1** — Extend `AuthRepository`'s interface and migrate the 12 Cubits off the concrete `AuthLocalDataSource`.
4. **7.2** — Replace manual `RepositoryImpl`/`RemoteDataSourceImpl` instantiation in the 5 flagged screens with the existing `getIt<T>()` registrations.

### Medium — real risk/impact, moderate effort
5. **3.2** — Add certificate pinning to the shared Dio client for release builds.
6. **2.4** — Stop manually replaying the refresh token as a `Cookie` header.
7. **5.5** — Actually redact the Agora RTC token before logging, gate behind `kDebugMode`.
8. **6.3** — Gate/redact Razorpay and wallet payment payload logging.
9. **8.4** — Add `buildWhen`/`BlocSelector` to `CallScreenCubit`'s outer consumer and other wide-scope `BlocBuilder`s.
10. **8.5** — Switch the recharge-history list to `ListView.builder`.
11. **8.3** — Move the synchronous file check out of `host_profile_avatar.dart`'s `build()`.
12. **4.4** — Explicitly cycle the presence socket on logout to avoid a stale-identity window on user switch.
13. **1.3** — Add background blur/placeholder overlay for sensitive screens.
14. **2.6** — Add a local failed-OTP-attempt lockout.
15. **7.4** — Split `CallScreenCubit`'s internal responsibilities into collaborator classes (behavior-preserving internal refactor).

### Low — hygiene/hardening, do opportunistically
16. **1.4** — Set `android:allowBackup="false"`.
17. **4.1/4.6** — Consolidate redundant socket auth fields; gate the `onAny` debug log.
18. **4.3** — Add explicit `.off()` calls before socket disposal.
19. **6.4** — Delete (or gate) the dead `NetworkLogger` class.
20. **3.5** — Introduce a shared `mapExceptionToFailure` helper instead of raw `e.toString()` in ~20 repositories.
21. **3.6** — Add `sendTimeout` to the shared Dio client.
22. **8.2** — Add the trivial missing `const` in `wallet_balance_card.dart`.

### Informational / backend dependency — no client-side action in this repo
23. **3.7** — Server must validate `callId`/`hostId` ownership against the bearer token subject on every relevant endpoint (cannot be verified or fixed from this client repo).
24. **1.2, 2.5** — Jailbreak detection and biometric gating are absent; note as optional future hardening requiring a product decision, not a defect.
25. **7.7** — No isolate/`compute()` usage exists yet; no current hot spot, but worth revisiting if host-presence/call-history payload sizes grow significantly as concurrency scales.
