# Mint-Talk read-only engineering audit

Audit date: 29 September 2026. Source: `/Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk`.

**Assessment: resolve the high-priority findings before a production release. This is a source audit with blocked runtime validation, not a completed penetration test, load test or release certification.**

The review identified **33 findings: 8 high, 23 medium and 2 low**. These are prioritized engineering findings, not 33 security vulnerabilities. No critical exploit or backend compromise was demonstrated. Severity reflects user impact and the affected workflow; it is not a CVSS score.

The main risks are account isolation, call lifecycle races, shared socket ownership, multipart authentication retries, misleading plan/balance data and withdrawal precision. Fix recommendations are provided; **no application code or configuration was changed**. Existing uncommitted changes were preserved and included in the reviewed snapshot.

## Scope and evidence

- Inventoried all 615 Dart source files (53,432 lines, including generated code); used project-wide searches and import/duplicate scans, followed by targeted manual tracing of high-risk and feature entry paths. This does not mean every line or branch was manually reviewed.
- Examined authentication/storage, REST/interceptors, presence/socket, Agora calling, payments/wallets, notifications/chat, profile/host application, leave, host analytics, settings, route wiring, native manifests, package locks and existing tests.
- The reviewed working tree had existing edits in 18 tracked files and three untracked directory/file entries at the initial snapshot. Source references point to that working tree, not merely HEAD.
- Isolated `lib`, tests, assets and package metadata under the audit workspace for attempted execution. Environment secrets were not copied into the test project and no live app API was called.
- Searched tracked text for selected credential patterns without printing values. No matches were found by that limited scan; this is not a historical secret scan or proof that secrets never existed. Real environment JSONs and signing keys are not tracked in the current file listing.
- No backend source, API specification verified against a running server, staging credentials or target-platform confirmation was supplied. Local PRD Markdown was treated as design context, not proof of server behavior.
- The existing `AUDIT_REPORT.md` was left unchanged; its section headings were inspected, but its conclusions were not accepted as evidence for this report.

## Execution record

| Check | Result |
|---|---|
| Source inventory, caller tracing, import graph and duplicate scan | Completed; see `audit-inventory.json` |
| Read-only source integrity comparison | Performed; final record in `verification-record.json` |
| Dart analysis on isolated copy | **Blocked before analysis**; process exited 134 |
| Flutter test with coverage on isolated copy | **Blocked before loading tests**; process exited 134 |
| Runtime failure | Dart 3.11.4 macos_x64 aborts at `runtime/vm/cpuinfo_macos.cc:42: error: unreachable code` when loading analysis/tests in this environment |
| Flutter wrapper | `flutter --version` is separately blocked because the SDK script cannot write `/Users/macbook/Documents/developer/flutter/bin/cache/engine.stamp`; this is an environment permission issue |
| Test declarations inventoried | 76 in 16 files; 0 widget test declarations |
| Actual passing / failing tests, line coverage | **Unknown**; no suite results or coverage generated |
| Android/iOS release builds and native UI | Not executed |
| Live REST/Socket.IO/Agora/payment scenarios | Not executed |
| Backend authorization, adversarial testing, load/soak | Not executed |
| Dependency version spot-check | Six important packages checked against publisher package pages |
| Full advisory/SBOM/native dependency scan | Not completed; no claim of vulnerability-free dependencies |

The Dart crash is an audit-environment blocker, not an application test failure and not evidence that Dart is broken in the user's normal terminal. The Flutter wrapper's engine-stamp permission error is a separate environment blocker. Raw process logs are included separately. The scenarios below are **tests to run**, not tests claimed as passed or reproduced on a device.

## Prioritized findings

| ID | Priority | Finding |
|---|---|---|
| MT-01 | High | Account data and call state survive logout / account switching |
| MT-02 | High | A cancelled call can restart when a delayed response completes |
| MT-03 | High | Closing an online-users page disconnects the shared app socket |
| MT-04 | High | Recreated sockets can reuse stale authentication options |
| MT-05 | High | 401 upload retry reuses finalized multipart data |
| MT-06 | High | Temporary refresh failures permanently erase the session |
| MT-07 | High | Static recharge plans override the authoritative API catalogue |
| MT-08 | High | Withdrawal amounts are silently rounded before transmission |
| MT-09 | Medium | Payment recovery relies on one in-memory transaction ID |
| MT-10 | Medium | Wallet refresh runs before call billing finishes |
| MT-11 | Medium | Several call failure exits leave resources active |
| MT-12 | Medium | Refresh completion can restore an access token after logout |
| MT-13 | Medium | Notification rollback and repeated events corrupt unread state |
| MT-14 | Medium | Chat lookup only searches the first 20 conversations |
| MT-15 | Medium | Chat retry changes the idempotency key |
| MT-16 | Medium | Profile edit reports success for explicit API failure |
| MT-17 | Medium | Host wallet history and totals stop at the first page |
| MT-18 | Medium | Host and favorites lists discard pagination metadata |
| MT-19 | Medium | Leave balance is fabricated as 12 days |
| MT-20 | Medium | Account deletion and multiple user actions do nothing |
| MT-21 | Medium | Call-reporting UI is unreachable from the application |
| MT-22 | Medium | Popping a screen during a request can cause emit-after-close errors |
| MT-23 | Medium | OTP submission has ineffective concurrency guards |
| MT-24 | Medium | Date-of-birth validators silently normalize invalid dates |
| MT-25 | Medium | Debug HTTP logs expose credentials and personal data |
| MT-26 | Medium | Every presence event traverses and formats the full host roster |
| MT-27 | Medium | Recharge listing starts network work inside build |
| MT-28 | Medium | Host profile edits can replace fresh server values with stale cached values |
| MT-29 | Medium | Missing payment/call data is presented as settled zero values |
| MT-30 | Medium | Legal screens still contain placeholder copy |
| MT-31 | Medium | Test coverage does not validate the UI or major end-to-end flows |
| MT-32 | Low | Unused UI families and duplicated implementations increase maintenance cost |
| MT-33 | Low | Large raster assets are an optimization opportunity |

### MT-01 — Account data and call state survive logout / account switching

**Priority: High. Evidence: Source-confirmed.**

**Location:** [lib/app.dart:29](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/app.dart:29>); [lib/features/auth/data/repositories/auth_repository_impl.dart:151](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/auth/data/repositories/auth_repository_impl.dart:151>); [lib/features/user_side/main_navigation/presentation/screen/main_navigation_screen.dart:55](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/main_navigation/presentation/screen/main_navigation_screen.dart:55>); [lib/core/services/socket/presence_socket_service.dart:563](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/services/socket/presence_socket_service.dart:563>)

**Evidence:** WalletCubit, NotificationsCubit and CallScreenCubit live above MaterialApp for the process lifetime. Logout clears stored auth and disconnects the socket, but does not reset these cubits or stop the RTC session. The login shell fetches wallet/notifications only while their status is initial. Forced session termination clears only tokens and navigates away.

**Impact:** After A logs out and B logs in without restarting, A’s notifications/balance can remain in memory and be rendered for B. A minimized call can also outlive authentication changes. This is a client-side isolation/privacy defect; it does not prove backend authorization bypass.

**Reproduction / acceptance check (not yet executed):** Load A’s balance and notifications, log out, sign in as B, inspect initial state and failed/offline refresh. Repeat during a minimized call and on session_terminated; camera/microphone and all A-specific state must stop/clear.

**Recommended update:** Create one session teardown path for explicit logout, revoked sessions and refresh rejection: invalidate in-flight work, stop calls, disconnect sockets, clear account-scoped state, then navigate. Scope cubits to the authenticated user or recreate them on identity changes.


### MT-02 — A cancelled call can restart when a delayed response completes

**Priority: High. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:144](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:144>); [lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:184](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:184>); [lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:1020](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:1020>); [lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:335](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:335>)

**Evidence:** Outgoing initiate and incoming accept await HTTP, then check only isClosed. endCall sets _hasTerminated and emits ended while the app-wide cubit stays open. The late success branch then emits ringing/session, subscribes and joins Agora. Permission and engine initialization awaits also lack a call-generation/termination check.

**Impact:** An end action during slow initiation, permission prompts or initialization can be undone; media setup may proceed after the user believes the call has ended. If initiation had not returned a session ID, no cancel request is sent for the subsequently-created server call.

**Reproduction / acceptance check (not yet executed):** Hold initiate/accept with a controllable Future, call endCall, then complete the Future successfully. Repeat by ending while permissions or Agora initialization are pending. Expect no join and a compensating server cancel/end.

**Recommended update:** Give each call attempt an immutable generation ID/cancellation token; check it after every await. Cancel a server session returned after local cancellation. Prevent overlapping starts.


### MT-03 — Closing an online-users page disconnects the shared app socket

**Priority: High. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/home/presentation/bloc/home_cubit.dart:410](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/home/presentation/bloc/home_cubit.dart:410>); [lib/features/user_side/online_users/presentation/screens/video_call.dart:23](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/online_users/presentation/screens/video_call.dart:23>); [lib/features/user_side/home/data/repositories/host_repository_impl.dart:76](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/home/data/repositories/host_repository_impl.dart:76>)

**Evidence:** The main shell owns a HomeCubit; audio/video online-user pages each construct another HomeCubit. All use the same singleton presence service. Every HomeCubit.close calls disconnectPresence, which disconnects the shared socket.

**Impact:** Open an online-user page and go back: the main home cubit remains alive but its presence/chat/notification/call-signaling transport has been intentionally disconnected. Home.refresh only reloads REST data and does not reconnect it.

**Reproduction / acceptance check (not yet executed):** From Home open Video Call or Audio Call, then back. Check socket disconnect, presence updates and incoming pushes. Repeat with a minimized call.

**Recommended update:** Move socket connection ownership to the authenticated session; screen cubits should cancel only their own subscriptions. Alternatively use explicit reference-counted subscriptions with a session owner.


### MT-04 — Recreated sockets can reuse stale authentication options

**Priority: High. Evidence: Source-confirmed.**

**Location:** [lib/core/services/socket/presence_socket_service.dart:208](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/services/socket/presence_socket_service.dart:208>); [lib/core/services/socket/presence_socket_service.dart:214](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/services/socket/presence_socket_service.dart:214>); [lib/core/services/socket/presence_socket_service.dart:324](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/services/socket/presence_socket_service.dart:324>)

**Evidence:** Creation uses io.io for the same root URL without forceNew/disableMultiplex. All four local environment configs use an empty URL path. Installed socket_io_client 3.1.6 caches managers; _lookup checks the empty path, but Manager.socket stores namespace / and returns an existing Socket without applying new opts. dispose does not evict the manager. Refresh/relogin can therefore reuse old auth/headers.

**Impact:** Expired credentials can persist through refresh attempts; switching users risks reconnecting a socket with the previous identity if that credential remains accepted. Server behavior determines the final outcome.

**Reproduction / acceptance check (not yet executed):** Use a local Socket.IO fixture with root URL and tokens A then B. Connect A, dispose/disconnect, reconnect B; inspect actual handshake auth/header and object reuse, without logging real credentials.

**Recommended update:** Use a new manager per session or explicitly update both socket auth and transport headers before reconnecting. Add a root-URL token-rotation regression test. See [Socket.IO client package guidance](https://pub.dev/packages/socket_io_client).


### MT-05 — 401 upload retry reuses finalized multipart data

**Priority: High. Evidence: Source-confirmed.**

**Location:** [lib/core/network/interceptors/auth_interceptor.dart:95](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/network/interceptors/auth_interceptor.dart:95>); [lib/core/network/api_client.dart:78](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/network/api_client.dart:78>)

**Evidence:** An authenticated multipart request is sent and finalized, gets 401, refreshes, then _dio.fetch retries the identical RequestOptions.data. Installed Dio 5.9.2 FormData.finalize throws when called twice; FormData.clone exists but is not used.

**Impact:** Avatar/selfie upload can fail at token expiry even when refresh succeeds. Ordinary JSON-request tests do not exercise this.

**Reproduction / acceptance check (not yet executed):** With a mocked transport, accept the upload body, respond 401, make refresh succeed, then inspect the retry. Expect two independent multipart bodies and one eventual upload success.

**Recommended update:** Clone or reconstruct FormData and MultipartFile streams for retry; preserve filenames and payload. Add multipart refresh tests. See [Dio multipart retry guidance](https://pub.dev/packages/dio).


### MT-06 — Temporary refresh failures permanently erase the session

**Priority: High. Evidence: Source-confirmed.**

**Location:** [lib/core/utils/token_manager.dart:85](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/utils/token_manager.dart:85>); [lib/core/utils/token_manager.dart:120](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/utils/token_manager.dart:120>); [lib/core/network/interceptors/auth_interceptor.dart:77](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/network/interceptors/auth_interceptor.dart:77>); [lib/core/services/socket/presence_socket_service.dart:663](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/services/socket/presence_socket_service.dart:663>)

**Evidence:** Token refresh collapses timeouts, no connectivity, 5xx, parse errors and rejected refresh tokens into false. REST and socket handlers interpret false as expired credentials, delete tokens and navigate to login.

**Impact:** A brief outage when the access token expires logs the user out and destroys an otherwise usable refresh token. This is especially disruptive during calls and checkout.

**Reproduction / acceptance check (not yet executed):** Return 401 for a protected request and simulate timeout/503 from refresh. Verify credentials remain and a recoverable network error is shown; separately verify actual revoked credentials trigger teardown.

**Recommended update:** Return typed refresh outcomes; clear credentials only on authoritative invalid/revoked-session responses. Add bounded backoff and offline recovery, sharing one refresh request.


### MT-07 — Static recharge plans override the authoritative API catalogue

**Priority: High. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/wallet/domain/usecases/merge_recharge_plans.dart:11](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/wallet/domain/usecases/merge_recharge_plans.dart:11>); [lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:166](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:166>); [lib/features/user_side/recharge_plans/presentation/widgets/screen_contents.dart:85](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/recharge_plans/presentation/widgets/screen_contents.dart:85>)

**Evidence:** Merging writes API plans first and fallbacks last into a map, so fallback wins for matching IDs. The screen additionally excludes API plans with any static ID and always renders static sections. API failure is emitted as plansLoaded with dummy plans.

**Impact:** Customers can see incorrect prices/points or non-existent plan IDs. The detail screen does re-fetch a selected plan, which limits checkout exposure but does not make the catalogue truthful.

**Reproduction / acceptance check (not yet executed):** Return an updated price for plan_10k, remove another static plan, then simulate plans failure. The current listing still renders static data; expected behavior is authoritative results or an explicit unavailable state.

**Recommended update:** Use API plans as the sole purchasable catalogue. If an offline cache is needed, persist actual server results with freshness metadata. Never synthesize purchasable IDs on failure.


### MT-08 — Withdrawal amounts are silently rounded before transmission

**Priority: High. Evidence: Source-confirmed.**

**Location:** [lib/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart:162](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_wallet/presentation/cubit/host_wallet_cubit.dart:162>); [lib/features/host_side/host_wallet/data/models/host_wallet_models.dart:71](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_wallet/data/models/host_wallet_models.dart:71>); [lib/features/host_side/host_wallet/data/models/host_wallet_models.dart:41](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_wallet/data/models/host_wallet_models.dart:41>)

**Evidence:** The form/cubit accepts decimal input but HostWithdrawalRequestModel serializes amount.round(). Overview parsing also rounds the available currency balance to an integer. The amount field has a numeric keyboard but no formatter rejecting pasted fractions.

**Impact:** Entering ₹500.60 transmits 501, while ₹500.40 transmits 500. Rounding balance upward can make a withdrawal appear allowed when it exceeds the true available funds.

**Reproduction / acceptance check (not yet executed):** With balance above ₹1000, submit 500.40 and 500.60 and inspect the request body. Also test a balance of 500.60 and a requested 501.

**Recommended update:** Agree on minor units or exact decimal amounts across backend and client. If only whole rupees are allowed, reject fractions explicitly before confirmation and preserve authoritative balance precision.


### MT-09 — Payment recovery relies on one in-memory transaction ID

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:31](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:31>); [lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:186](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:186>); [lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:68](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:68>)

**Evidence:** _lastTransactionId is memory-only and overwritten by each order. No pending-order persistence/recovery path is present. startRecharge has no in-flight guard, and the button only disables for paymentProcessing, not orderCreated. An unknown verification outcome is represented as paymentFailure.

**Impact:** Process death during checkout or overlapping attempts can leave the client unable to correlate/verify a successful payment. A network failure after payment can be shown as failure and encourage another purchase. Backend webhooks may repair crediting, but that is unverified.

**Reproduction / acceptance check (not yet executed):** Use payment test mode: background/kill during external checkout, resume/relaunch, simulate lost verify response, and trigger duplicate taps. Confirm one credit and a recoverable pending state.

**Recommended update:** Persist user-scoped pending order IDs, lock checkout until resolved, distinguish pending from failed, and reconcile via server payment status plus idempotent webhooks. Never infer paid status from the client callback alone.


### MT-10 — Wallet refresh runs before call billing finishes

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/app.dart:55](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/app.dart:55>); [lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:531](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:531>); [lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:1080](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:1080>)

**Evidence:** endCall emits ended before the asynchronous /end request. The root listener immediately fetches balance. Reconciliation returns updated billing fields but its result is ignored; there is no corresponding balance refresh on confirmed reconciliation.

**Impact:** The wallet can retain the pre-call balance after a successful call until manual refresh or another operation.

**Reproduction / acceptance check (not yet executed):** Delay /calls/{id}/end; respond to the first balance GET before finalizing billing. Complete /end and verify the wallet eventually fetches the finalized balance.

**Recommended update:** Keep immediate local media termination, but publish a separate billing-confirmed/pending event and refresh wallet on confirmation. Handle failed reconciliation explicitly.


### MT-11 — Several call failure exits leave resources active

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:154](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:154>); [lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:348](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_screen_cubit.dart:348>); [lib/features/user_side/call/presentation/widgets/call_screen_contents.dart:475](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/widgets/call_screen_contents.dart:475>)

**Evidence:** Initiate/accept failures emit failed without cleanup. The permission-denied branch returns without cleanup or terminating an already-created server session. Failure UI pops the screen, but the call cubit is app-scoped and remains open. _cleanupResources also does not cancel _controlsAutoHideTimer.

**Impact:** Wakelock can stay enabled; a denied call can remain ringing on the server; subscriptions or an old control-hide timer can affect subsequent calls. These paths require device verification for exact resource behavior.

**Reproduction / acceptance check (not yet executed):** Deny microphone/camera, return busy/insufficient funds during initiate, and fail accept. Check wakelock, server session, subscriptions and delayed timer events after navigation.

**Recommended update:** Use a single idempotent terminal cleanup path for failed/ended/cancelled states, cancel all timers, and compensate server sessions when local setup cannot complete.


### MT-12 — Refresh completion can restore an access token after logout

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/core/utils/token_manager.dart:45](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/utils/token_manager.dart:45>); [lib/core/utils/token_manager.dart:79](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/utils/token_manager.dart:79>); [lib/core/utils/token_manager.dart:114](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/utils/token_manager.dart:114>)

**Evidence:** clearAll deletes current tokens but does not invalidate _refreshInFlight. A refresh already awaiting the server can later call saveAccessToken and return success. Socket recovery can similarly continue after its delay without checking a session generation.

**Impact:** Asynchronous work from a prior session can reintroduce credentials after logout or after another account logs in.

**Reproduction / acceptance check (not yet executed):** Begin refresh with a held response, call clearAll/logout, then complete refresh; access token must remain absent and no reconnect may happen.

**Recommended update:** Increment a session generation on logout and login; only commit refresh results belonging to the active generation. Cancel pending refresh/reconnect work.


### MT-13 — Notification rollback and repeated events corrupt unread state

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/shared/notifications/presentation/cubit/notifications_cubit.dart:105](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/notifications/presentation/cubit/notifications_cubit.dart:105>); [lib/features/shared/notifications/presentation/cubit/notifications_cubit.dart:116](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/notifications/presentation/cubit/notifications_cubit.dart:116>); [lib/features/shared/notifications/presentation/cubit/notifications_cubit.dart:124](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/notifications/presentation/cubit/notifications_cubit.dart:124>)

**Evidence:** markAllAsRead captures the old list but not the old unread count. It sets count to zero, then on failure restores the list with the current count, still zero. Incoming events append unconditionally and increment count even for duplicates or already-read notifications.

**Impact:** Unread items can coexist with a zero badge, and duplicate delivery inflates both list and badge.

**Reproduction / acceptance check (not yet executed):** Start with five unread notifications; reject read-all. Expected badge is five. Replay the same notification ID twice and send isRead=true; count must stay accurate.

**Recommended update:** Capture and reconcile the previous count with events arriving during the request. Upsert by stable ID and increment only for a newly-unread notification; deduplicate pagination too.


### MT-14 — Chat lookup only searches the first 20 conversations

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/shared/chat/presentation/cubit/chat_thread_cubit.dart:232](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/chat/presentation/cubit/chat_thread_cubit.dart:232>); [lib/features/shared/chat/presentation/cubit/chat_thread_cubit.dart:234](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/chat/presentation/cubit/chat_thread_cubit.dart:234>)

**Evidence:** Opening chat from a profile without a conversationId searches only page 1 for the recipient. If an existing conversation is older than the first 20, init treats it as new and skips loading its messages.

**Impact:** Existing history appears empty for users with many conversations. This is a functional scalability limit, independent of server throughput.

**Reproduction / acceptance check (not yet executed):** Create 21+ conversations and open the oldest recipient from their profile. Verify its history appears without first sending another message.

**Recommended update:** Add direct recipient-to-conversation lookup or follow pagination until found; retain stable conversation IDs in navigation where available.


### MT-15 — Chat retry changes the idempotency key

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/shared/chat/presentation/cubit/chat_thread_cubit.dart:96](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/chat/presentation/cubit/chat_thread_cubit.dart:96>); [lib/features/shared/chat/presentation/cubit/chat_thread_cubit.dart:115](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/chat/presentation/cubit/chat_thread_cubit.dart:115>)

**Evidence:** retryMessage drops the failed optimistic entry and calls _sendContent, which generates a new clientMessageId. A timed-out request may already have been accepted by the backend.

**Impact:** Retry can create a duplicate message instead of resolving the original operation. A socket echo arriving before REST failure can also leave real plus failed optimistic entries because merging is by server ID only.

**Reproduction / acceptance check (not yet executed):** Accept the send server-side but lose its response; then retry. Replay the socket echo before and after the REST result. Expect exactly one logical message.

**Recommended update:** Reuse the original clientMessageId across retries and reconcile optimistic/real entries by that ID as well as server ID. Confirm backend deduplicates the same key.


### MT-16 — Profile edit reports success for explicit API failure

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/host_side/host_profile_edit/data/datasources/host_profile_remote_datasource.dart:49](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_profile_edit/data/datasources/host_profile_remote_datasource.dart:49>); [lib/features/host_side/host_profile_edit/presentation/cubit/host_profile_edit_cubit.dart:150](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_profile_edit/presentation/cubit/host_profile_edit_cubit.dart:150>)

**Evidence:** Host profile update returns true for any nonempty response, including {success:false,message:...}. The cubit also ignores the returned boolean on Right and saves local fields as successful.

**Impact:** A server-rejected update can be displayed and cached as saved, leaving client and backend inconsistent.

**Reproduction / acceptance check (not yet executed):** Return HTTP 200 with success:false, and separately Right(false) from the use case. Expect a visible failure and unchanged cached profile.

**Recommended update:** Require an explicit success contract, reject explicit failure payloads, and check the returned result before mutating local profile data.


### MT-17 — Host wallet history and totals stop at the first page

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/host_side/host_wallet/domain/usecases/get_host_wallet_overview_usecase.dart:17](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_wallet/domain/usecases/get_host_wallet_overview_usecase.dart:17>); [lib/features/host_side/host_wallet/data/datasources/host_wallet_remote_datasource.dart:11](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_wallet/data/datasources/host_wallet_remote_datasource.dart:11>); [lib/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart:46](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_wallet/domain/entities/host_wallet_entities.dart:46>)

**Evidence:** The data source supports pages but the use case takes NoParams and always requests page 1/20. No loadMore exists in HostWalletCubit. Approved/pending summary totals sum only withdrawals in that page.

**Impact:** Older withdrawals are inaccessible; summaries can materially understate lifetime approved or pending amounts.

**Reproduction / acceptance check (not yet executed):** Seed 25+ withdrawals with nonzero approved/pending entries beyond the first 20. Compare UI totals and history to server records.

**Recommended update:** Expose pagination through the full stack; fetch authoritative aggregate totals separately, with explicit scope labels.


### MT-18 — Host and favorites lists discard pagination metadata

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/home/presentation/bloc/home_cubit.dart:94](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/home/presentation/bloc/home_cubit.dart:94>); [lib/features/user_side/home/presentation/bloc/home_cubit.dart:135](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/home/presentation/bloc/home_cubit.dart:135>); [lib/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart:202](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_dash/presentation/cubit/host_dash_cubit.dart:202>)

**Evidence:** Home and host-dashboard roster loading request only one page; favorite loading explicitly caps at 50. UI exposes no continuation for either. Presence updates do not supply complete display profiles for users outside the REST page.

**Impact:** Users with larger rosters/favorite sets miss results or see incomplete names/avatars despite valid server records.

**Reproduction / acceptance check (not yet executed):** Seed more than one host page and 51 favorites; verify the last item is reachable, with correct profile data.

**Recommended update:** Implement paged list state and server-side filters, or direct profile lookup for presence-only IDs. Do not solve by requesting arbitrarily large single pages.


### MT-19 — Leave balance is fabricated as 12 days

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/host_side/apply_for_leave/data/datasources/leave_remote_datasource.dart:49](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/apply_for_leave/data/datasources/leave_remote_datasource.dart:49>); [lib/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart:123](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart:123>)

**Evidence:** getAvailableDays returns 12 without contacting an API. Successful requests reload history but not available days.

**Impact:** Every host sees the same allowance regardless of policy or usage, so leave eligibility information is inaccurate.

**Reproduction / acceptance check (not yet executed):** Use hosts with different leave balances and submit leave; the displayed balance must reflect server-authoritative data.

**Recommended update:** Wire a documented leave-balance endpoint, refresh after submission, and represent unavailable data explicitly rather than using a numeric placeholder.


### MT-20 — Account deletion and multiple user actions do nothing

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/settings/presentation/widgets/settings_contents.dart:125](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/settings/presentation/widgets/settings_contents.dart:125>); [lib/features/user_side/settings/presentation/widgets/settings_contents.dart:89](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/settings/presentation/widgets/settings_contents.dart:89>); [lib/features/user_side/settings/presentation/widgets/contact_us_bottom_sheet.dart:89](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/settings/presentation/widgets/contact_us_bottom_sheet.dart:89>); [lib/features/user_side/home/presentation/bloc/home_cubit.dart:292](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/home/presentation/bloc/home_cubit.dart:292>)

**Evidence:** Confirmed live user flows have empty handlers for Delete Account confirmation, Terms and Conditions, About Us and the WhatsApp support button. Home.notifyUser only emits a toast promising a future notification; it registers no subscription or server request.

**Impact:** The app presents actions as functional when they are not. Account deletion and support are particularly important user trust gaps; legal compliance is not assessed here.

**Reproduction / acceptance check (not yet executed):** Tap and confirm each action; verify an actual deletion request/completion, legal/about navigation, support launch, and a durable notify-me subscription.

**Recommended update:** Implement the promised workflows or clearly disable them until available. Delete-account must have explicit backend confirmation and session cleanup; notify-me needs server-side persistence and delivery.


### MT-21 — Call-reporting UI is unreachable from the application

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/shared/call_report/presentation/widgets/report_call_bottom_sheet.dart:9](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/call_report/presentation/widgets/report_call_bottom_sheet.dart:9>)

**Evidence:** The report sheet, cubit, repository and endpoint exist, but no app file imports or opens ReportCallBottomSheet. Import graph traversal from main marks the sheet unreachable; searches find no alternative live call-report submission UI.

**Impact:** Users cannot access the implemented misconduct-reporting flow after a call.

**Reproduction / acceptance check (not yet executed):** Inspect user/host call screens, summary and call history for a report action. Exercise submission once wired and verify the correct call ID is used.

**Recommended update:** Connect reporting to the appropriate call/history UI with success, failure and duplicate-submission handling; include it in acceptance tests.


### MT-22 — Popping a screen during a request can cause emit-after-close errors

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/recharge_plans/presentation/cubit/plan_detail_cubit.dart:24](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/recharge_plans/presentation/cubit/plan_detail_cubit.dart:24>); [lib/features/shared/profile/presentation/cubit/profile_image_cubit.dart:17](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/shared/profile/presentation/cubit/profile_image_cubit.dart:17>); [lib/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart:64](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/apply_for_leave/presentation/cubit/apply_for_leave_cubit.dart:64>)

**Evidence:** Screen-owned cubits await requests then emit without isClosed checks or cancellation. This pattern is present in plan detail, profile image, leave, host wallet and several other cubits. ApiClient supports CancelToken but no feature caller passes one.

**Impact:** Navigating away during a slow request can throw StateError on completion and leave unhandled asynchronous errors. The presence of guards in some other cubits does not protect these paths.

**Reproduction / acceptance check (not yet executed):** Hold a request, dispose its provider by popping the screen, complete the request successfully and with an error, and assert no subsequent state emission or uncaught error.

**Recommended update:** Cancel screen-scoped operations and guard completion, using a consistent pattern. Also protect against stale results from an earlier request replacing a newer one.


### MT-23 — OTP submission has ineffective concurrency guards

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart:63](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart:63>); [lib/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart:93](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart:93>); [lib/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart:191](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/auth/presentation/screens/otp_verification/presentation/cubit/otp_verification/otp_verification_cubit.dart:191>)

**Evidence:** otpChanged and SMS autofill first set status to initial and then test whether status is submitting, making that guard ineffective. submitOtp has no own in-flight guard. resendOtp guards cooldown but not an already-pending resend before success sets the cooldown.

**Impact:** Rapid editing/autofill/manual submit can send multiple verifications, causing response races, conflicting UI states and unnecessary OTP/rate-limit pressure.

**Reproduction / acceptance check (not yet executed):** Hold verify response and trigger a complete code via SMS and editing/manual submission; assert one request. Repeat resend twice while its first response is pending.

**Recommended update:** Guard at the operation entry point, preserve submission state during edits, and discard stale verification responses. Backend rate limiting remains independently required.


### MT-24 — Date-of-birth validators silently normalize invalid dates

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/core/utils/validators.dart:80](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/utils/validators.dart:80>); [lib/features/user_side/profile_setup/domain/value_objects/dob.dart:15](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/profile_setup/domain/value_objects/dob.dart:15>)

**Evidence:** Both date validators construct DateTime directly and only check age. Dart normalizes out-of-range components; neither compares parsed day/month/year back to the input. For example 31/02/2000 becomes a date in March and passes adult validation.

**Impact:** Bad dates can be accepted and serialized as different dates. Date-picker restrictions mitigate ordinary taps but do not validate cached/imported or direct value-object input.

**Reproduction / acceptance check (not yet executed):** Test 31/02/2000, 00/01/2000, 01/13/2000, leap years, future dates and exact eighteenth birthday; invalid calendar dates must be rejected.

**Recommended update:** Use one shared strict calendar validator with round-trip component equality and explicit age bounds. Apply it consistently to host edits, user setup/edit and host applications.


### MT-25 — Debug HTTP logs expose credentials and personal data

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/core/network/interceptors/logger_interceptor.dart:21](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/network/interceptors/logger_interceptor.dart:21>); [lib/core/network/interceptors/logger_interceptor.dart:31](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/network/interceptors/logger_interceptor.dart:31>)

**Evidence:** LoggerInterceptor logs all request headers and bodies and all response bodies in debug mode. AuthInterceptor runs first, so bearer tokens are included; OTP, phone, profile, banking and token responses can also reach logs. This path is gated by kDebugMode, so this is not a demonstrated release-log leak.

**Impact:** Test/dev logs, screen shares and copied diagnostics can expose live credentials or personal information when debug builds use real accounts.

**Reproduction / acceptance check (not yet executed):** Use synthetic tokens, OTPs and bank details in a debug fixture and inspect captured log output. Verify redaction in both success and error paths.

**Recommended update:** Redact Authorization/Cookie/Set-Cookie and sensitive body fields recursively. Prefer method, route template, status, latency and request ID over payloads.


### MT-26 — Every presence event traverses and formats the full host roster

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/home/presentation/bloc/home_cubit.dart:217](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/home/presentation/bloc/home_cubit.dart:217>); [lib/features/user_side/home/presentation/bloc/home_cubit.dart:320](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/home/presentation/bloc/home_cubit.dart:320>)

**Evidence:** Each presence event filters the roster, iterates every host to construct verbose log strings, and emits a newly built list. Setting appLogger level off prevents output, but does not skip the caller’s loop and interpolation. A burst of N distinct host events performs approximately quadratic aggregate work while the map grows.

**Impact:** Large presence snapshots can create excessive allocation and main-isolate work, risking UI jank and battery overhead. No frame-rate claim is made without profiling.

**Reproduction / acceptance check (not yet executed):** Profile release-like builds with 100/1000/10000 host events and controlled rates. Measure frame time, allocations and CPU with and without full-roster logging and batched updates.

**Recommended update:** Remove/gate diagnostic loops before interpolation, coalesce snapshot events per frame, maintain bounded/paged visible state, and use narrower UI selectors. Measure before broader rewrites.


### MT-27 — Recharge listing starts network work inside build

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/recharge_plans/presentation/widgets/screen_contents.dart:24](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/recharge_plans/presentation/widgets/screen_contents.dart:24>); [lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:151](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/wallet/presentation/cubit/wallet_cubit.dart:151>)

**Evidence:** ScreenContents.build invokes fetchPlans unconditionally; fetchPlans has no in-flight/cache guard and emits loading immediately. Parent rebuilds can repeat requests, reset the shared wallet status and race response ordering.

**Impact:** Unnecessary requests and loading flicker; state emission during rebuilding can also conflict with existing listeners. This is not claimed to be an unconditional infinite rebuild loop.

**Reproduction / acceptance check (not yet executed):** Rebuild the parent due to constraints/theme changes while a plan request is pending, and count requests. Verify existing payment/balance state is not overwritten.

**Recommended update:** Load once in a lifecycle method/provider initializer, support explicit refresh, and separate catalogue state from payment/balance state.


### MT-28 — Host profile edits can replace fresh server values with stale cached values

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/host_side/host_profile_edit/presentation/cubit/host_profile_edit_cubit.dart:49](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_profile_edit/presentation/cubit/host_profile_edit_cubit.dart:49>); [lib/features/host_side/host_profile_edit/presentation/cubit/host_profile_edit_cubit.dart:162](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/host_profile_edit/presentation/cubit/host_profile_edit_cubit.dart:162>); [lib/features/auth/data/repositories/auth_repository_impl.dart:122](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/auth/data/repositories/auth_repository_impl.dart:122>)

**Evidence:** Host edit successfully fetches a current server profile, then prefers any nonempty locally cached name, DOB and avatar over that response. Startup current-user synchronization only writes role. Saving an unrelated field can therefore send old profile values back.

**Impact:** Changes made elsewhere or by support can be reverted by this device’s next edit.

**Reproduction / acceptance check (not yet executed):** Cache profile A, make a server-side change to B, reopen edit, change only categories and save. B’s other fields must stay unchanged.

**Recommended update:** Prefer fetched profile values, refresh the cache atomically, and submit only changed fields or use a version/ETag conflict policy.


### MT-29 — Missing payment/call data is presented as settled zero values

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/user_side/wallet/data/datasources/wallet_remote_datasource.dart:145](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/wallet/data/datasources/wallet_remote_datasource.dart:145>); [lib/features/user_side/call/presentation/bloc/call_summary_cubit.dart:79](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_summary_cubit.dart:79>); [lib/features/user_side/call/presentation/bloc/call_summary_cubit.dart:124](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/call/presentation/bloc/call_summary_cubit.dart:124>)

**Evidence:** Payment verification falls back to balance 0 if the success body has no balance; if the follow-up balance fetch also fails, that 0 becomes displayed balance. Call summary retries three times, then reveals initial/default metrics even if every details request failed and no final billing was retrieved.

**Impact:** Unknown balance/duration/billing can be shown as actual zero, undermining financial accuracy and making delayed settlement look final.

**Reproduction / acceptance check (not yet executed):** Return payment success without balance, fail the balance GET; then end a call and fail every details GET. Expect pending/unknown states retaining clearly-labeled last-known values, not settled zeros.

**Recommended update:** Use nullable/typed unknown values and an explicit settlement status. Display retryable pending data until authoritative results arrive; separate UI formatting from domain precision.


### MT-30 — Legal screens still contain placeholder copy

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [lib/features/host_side/privacy_policy/presentation/screen/privacy_policy.dart:42](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/privacy_policy/presentation/screen/privacy_policy.dart:42>); [lib/features/host_side/terms_and_conditions/presentation/screen/terms_and_conditions.dart:47](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/terms_and_conditions/presentation/screen/terms_and_conditions.dart:47>)

**Evidence:** Host privacy and terms screens explicitly contain placeholder text. Separately, profile-edit serializers include termsAcceptedAt and may generate a current timestamp if cached acceptance is missing, without a new acceptance action.

**Impact:** User-facing disclosures are unfinished and consent metadata can misrepresent what happened. This finding concerns implementation/data integrity, not a legal compliance determination.

**Reproduction / acceptance check (not yet executed):** Inspect the shipped legal routes and edit a profile with missing acceptance metadata. Verify no new consent is inferred merely from editing.

**Recommended update:** Publish approved versioned content and record acceptance only after explicit user action, with version and server timestamp. Keep routine profile edits separate from consent updates.


### MT-31 — Test coverage does not validate the UI or major end-to-end flows

**Priority: Medium. Evidence: Source-confirmed.**

**Location:** [test/widget_test.dart:5](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/test/widget_test.dart:5>); [test/features/online_users/presentation/cubit/online_users_cubit_test.dart:10](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/test/features/online_users/presentation/cubit/online_users_cubit_test.dart:10>); [analysis_options.yaml:10](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/analysis_options.yaml:10>)

**Evidence:** There are 16 test files and 76 test declarations, zero testWidgets calls and no integration_test directory. widget_test only asserts true. OnlineUsersCubit tests construct without a repository, so users stays empty and every loop-based filtering assertion is vacuous. No tracked CI workflow was found in common locations.

**Impact:** Existing meaningful model/auth/call tests provide partial protection, but cannot establish UI correctness, native integrations or release readiness. No passing-test or coverage percentage is asserted.

**Reproduction / acceptance check (not yet executed):** After restoring test execution, run the existing suite and measure coverage; add focused regressions for the high findings and complete real-device flows in the test matrix.

**Recommended update:** Replace vacuous checks with nonempty fixtures, add widget and integration coverage around actual risks, and gate changes on analysis/test/build checks in CI. Do not write tests merely mirroring implementation.


### MT-32 — Unused UI families and duplicated implementations increase maintenance cost

**Priority: Low. Evidence: Source-confirmed.**

**Location:** [lib/core/network/network_error_handler.dart:6](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/core/network/network_error_handler.dart:6>); [lib/features/user_side/chat/presentation/widgets/user_chat_contents.dart:11](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/user_side/chat/presentation/widgets/user_chat_contents.dart:11>); [lib/features/host_side/chat/presentation/widgets/host_chat_contents.dart:11](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/lib/features/host_side/chat/presentation/widgets/host_chat_contents.dart:11>)

**Evidence:** Import/export/part traversal from main found 24 unreachable file candidates. A normalized 12-nonempty-line scan found 25 duplicate file groups, including host/user chat and contact/list UI. Some groups are intentional DTO/entity boilerplate, not automatic refactoring targets. Generated DI references also keep unused features apparently reachable.

**Impact:** Parallel copies drift: for example host support has a launcher while user support is empty. Dead-code candidates cost maintenance but are not proof of shipped binary overhead because tree shaking may remove them.

**Reproduction / acceptance check (not yet executed):** Review the inventory and check generated factories, route usage and intended future features before deleting anything. Compare host/user behavior after any later consolidation.

**Recommended update:** Share true common UI/logic, retain explicit role-specific behavior, remove proven obsolete files and stale registrations, and decompose the 1469-line call cubit around lifecycle responsibilities. No deletions were performed.


### MT-33 — Large raster assets are an optimization opportunity

**Priority: Low. Evidence: Source-confirmed.**

**Location:** [pubspec.yaml:84](</Users/macbook/Desktop/projects/Learnig /mint-t/Mint-Talk/pubspec.yaml:84>)

**Evidence:** The assets tree totals 13,904,220 bytes. Six individual PNGs exceed 1 MB. Source inspection also finds images rendered into small avatars without consistent decode-size hints. Asset size alone does not measure installed app size or runtime memory.

**Impact:** Potential extra download, decode and image-cache cost, especially during onboarding and avatar-heavy screens.

**Reproduction / acceptance check (not yet executed):** Measure release app-size breakdown and image decode memory on target devices; visually compare compressed/resized alternatives before adopting them.

**Recommended update:** Right-size assets, test lossless/lossy formats appropriate to artwork and transparency, and set decode dimensions for small images. Keep a visual-quality check.

## Conditional risks and verification items

These observations need backend, build or device evidence before they can be classified as proven production vulnerabilities. They are **not included in the 33 source-confirmed findings above**.

| Area | Source observation | Required verification / update |
|---|---|---|
| Refresh-token rotation | `TokenManager._performRefresh` reads only the returned accessToken, never a rotated Set-Cookie refresh token. Login does extract refresh cookies. | If the refresh endpoint rotates tokens, securely replace the stored refresh token atomically; test consecutive refreshes and replay rejection. If it intentionally does not rotate, document that contract. |
| Refresh transport | Refresh creates a new Dio instance outside the shared transport configuration and never closes it explicitly. | Use a dedicated, consistently-configured refresh client without recursive auth interception. If pinning is later enabled, cover refresh and sockets too. Lack of pinning alone is not reported as a vulnerability. |
| TLS/config validation | Startup checks only that BASE_URL and SOCKET_URL are nonempty. Configs inspected use secure schemes, but no release scheme/host validation or environment allowlist exists. | Add build-time environment validation, including Agora/key availability where required. Verify HTTPS/WSS and intended host/environment before release. Compiled dart-defines are extractable from a client; do not put server secrets in them. Public Agora app IDs and Razorpay key IDs are not server secrets. |
| KYC selfie handling | Host application `uploadImage(path, 'selfieUrl')` posts to the normal `/user/avatar` endpoint and submits the resulting avatar URL as the verification selfie. Profile-image code says avatar URLs are stable across replacements. | Determine whether backend copies and retains an immutable KYC object. Otherwise later avatar replacement may alter the submitted evidence or a verification photo may become publicly served as an avatar. Use dedicated access-controlled immutable verification media if required. Client camera-only picking is not liveness proof. |
| Payment/withdrawal authorization | Client sends planId, userId, order/transaction IDs, signature and withdrawal details. | Verify ownership, server-authoritative amounts, signature verification, idempotency, atomic balance updates and webhook reconciliation. Client validation cannot establish these guarantees. No financial transaction was made in this audit. |
| Screenshot protection | `main.dart` comments out ScreenProtector.preventScreenshotOn; background overlay is still installed. | Confirm privacy requirements for calls/verification/bank data and test screenshot, recording, recents and lifecycle behavior on each target OS. Do not treat a Flutter overlay as an OS screenshot guarantee. |
| Background/terminated calls | Incoming calls use a foreground Socket.IO listener; no PushKit/CallKit/Android incoming-call or foreground-service integration was found in the application files reviewed. The PRD specifically flags background handling. | If background/locked/terminated incoming calls are a requirement, implement the appropriate platform-supported call delivery/lifecycle integration and test it. A screen wakelock does not by itself guarantee background execution. |
| macOS / web / other desktop | macOS entitlements lack outgoing network client capability; Info.plist lacks camera/microphone usage descriptions. Core paths use dart:io and file-backed upload APIs; Razorpay Flutter is Android/iOS only. | Confirm supported targets. If macOS is supported, add required capabilities and permissions and test a signed release. For web/other desktop, audit platform adapters, plugin support and browser cookie/CORS behavior. Platform folders alone do not establish feature support. |
| Release shrinking / SDK reproducibility | Android minification is enabled; project ProGuard rules lack the Razorpay rules listed by its publisher. Installed Razorpay plugin declares native `com.razorpay:checkout:1.6.+`. | Inspect merged consumer rules and resolved Gradle dependencies before calling this a release break. Run signed minified checkout callbacks and lock/verify native artifacts for reproducible releases. See [publisher guidance](https://pub.dev/packages/razorpay_flutter). |
| Backend/data-store scale | No backend, database indexes, infrastructure, telemetry or load target was available. | Test concurrent call activation/end, reconnect storms, fan-out, wallet locks, query plans and idempotent workers against staging. No supported concurrency figure or capacity estimate can be inferred from this Flutter repository. |

## Feature coverage and remaining acceptance tests

All rows below received source-level inspection of the listed paths or cross-cutting integration. **Runtime status is not executed for every row**. This matrix is a work plan, not a pass certificate. It covers the feature groups discovered; it is not a claim to enumerate every possible interaction.

| Feature / surface | Source assessment | Runtime acceptance cases still needed |
|---|---|---|
| Bootstrap / environments / DI | Env selection, required-variable guard, registrations reviewed; limited validation | Missing variables; invalid ENV; wrong host; staging isolation; cold/warm start; supported platform builds |
| Phone input / send OTP | Normalization, number validation and repository flow inspected | Valid/invalid international numbers; back navigation; resend; server 429 with retry timing; offline |
| OTP / SMS autofill | Concurrency and lifecycle gaps, MT-23/22 | Wrong/expired/used OTP; paste; autofill plus submit; duplicate taps; process death; permissions |
| Session startup / refresh | In-memory access and secure refresh; MT-01/04/05/06/12 | Valid/expired/revoked refresh; 401 storms; rotated cookies; 5xx; logout during refresh; two accounts |
| Logout / forced logout | Storage/socket cleanup exists but session teardown incomplete | A-to-B switch; offline logout; expired token; session_terminated during minimized call/payment |
| Profile setup / editing | Value objects and upload path inspected; MT-16/24/28/30 | Boundaries, Unicode, invalid dates, adult threshold, cached-vs-live data, server false response, upload failure |
| Host application / terms / join | API/status paths and per-user local flags exist; KYC media needs backend review | Eligible/ineligible; duplicate pending; accepted/rejected; role switch; selfie replacement; interrupted upload |
| Home / presence | Shared socket ownership and page limits; MT-03/18/26 | Initial snapshot; offline/busy transitions; duplicate/out-of-order events; reconnect; 1000+ hosts |
| Audio/video host browsing | Both routes instantiate independent HomeCubit and same UserGrid | Back navigation preserves signaling; audio-only/video-only availability; selection semantics; stale card |
| Favorites | API-backed main home list; first 50 only | Add/remove failure; rapid toggle; 51+ favorites; details/home consistency; account switch |
| Host dashboard / availability | Ready/stop/pickup/preferences paths inspected; dashboard data source still returns mock metrics | Preference failure rollback; accept-vs-cancel race; reconnect restores intended availability; self-card requirement |
| Calls / Agora setup | Substantial lifecycle logic and unit tests exist; MT-02/11 | Start/cancel during every await; permissions; audio/video; remote busy; duplicate start; camera/mic/speaker |
| Calls / ongoing lifecycle | Reconnect, activation retry, token-renewal paths inspected | Wi-Fi/cellular/offline handover; token expiry; remote loss; Bluetooth; interruption; lock screen; minimize/restore |
| Calls / billing / summary | Local immediate end plus background server reconciliation; MT-10/29 | Lost /end response; duplicate end; both peers end; insufficient points; 0/59/60/61 sec; stale settlement |
| Recharge catalogue / detail | API fetch exists but static catalogue overrides, MT-07/27 | Price changes; removed plans; empty response; failure; expired auth; repeated parent rebuild |
| Orders / checkout / verify | Server order creation and verification exist; MT-09/29 | Test-mode success/fail/cancel; external wallet; lost callback; process death; duplicate callback; webhook |
| User wallet / recharge history | Balance refresh and client slicing inspected | Fractional points; missing balance; account switching; long history; server paging; verification delay |
| Host wallet / withdrawals | Precision and first-page aggregate errors, MT-08/17 | Fractional input; minimum; invalid destination; insufficient funds; concurrent requests; 25+ withdrawals |
| Bank details / UPI | Banks stored in cubit memory; basic nonempty/matching checks | Reopen/restart persistence expectations; IFSC/account/UPI validation; masking; duplicate submissions |
| Referral status | Cached code fallback synthesizes pending/zero on API failure | Known approved referral while offline; pending/rejected/rewarded; ownership; missing response; stale labeling |
| Chat list | Paged REST plus socket updates; no event deduplication; unknown threads refetch page 1 | Duplicate/new events; bursts; 21+ threads; unread sync after viewing; pagination overlap |
| Chat thread | Optimistic send, merge, read and delivery acknowledgments; MT-14/15 | Timeout after acceptance; idempotent retry; older conversation; page overlap; ordering; read/delivery events |
| Notifications | Read and read-all APIs exist; rollback/dedupe errors MT-13 | Failed optimistic updates; repeated push; read notification push; concurrent pagination; new push during read-all |
| Blocking / safety | Block/unblock wired, failure handling can replace loaded state; report UI unwired MT-21 | Blocked parties cannot call/message server-side; failed block/unblock keeps truthful UI; report end-to-end |
| Host leave | Submit/history exist, allowance hardcoded MT-19 | Actual allowance; date range and policy; overlap; rejected request; 21+ history; refresh balance |
| Host analytics / targets | Parallel ledger/stats/target fetches exist; secondary failures fall back to empty/null | Partial failure shown distinctly from true zero; large ledger pages; date ranges; currency/points agreement |
| Settings / legal / support | Dead actions and placeholder copy MT-20/30 | Every tap produces correct action; account deletion lifecycle; actual support destination; correct legal version |
| Navigation / accessibility / layout | Routes and major widget composition reviewed; no rendered verification | Back/deep-link args; wrong-role routes; narrow/large screens; 200% text; screen reader labels; contrast; keyboard |
| Native permissions / privacy | Android and iOS camera/mic setup present; desktop and background gaps | Denied/permanently denied; settings return; screenshot/recents; gallery/camera interruption; lost image recovery |
| Release / delivery | Android signing guard/minification present; no CI found | Signed APK/AAB and iOS archive; callback under shrinker; fresh install/upgrade; store-distribution requirements |

### Specific cases that deserve the first regression tests

1. A signs out and B signs in: zero A-owned data, subscriptions, payment correlation or media survives.
2. Hold initiate/accept/permission/engine initialization, then end: no late response restarts the call.
3. Open an audio/video browsing page and return: existing socket subscribers remain connected.
4. Root Socket.IO URL connects with A then B: handshake actually uses B; no cached credentials.
5. Upload body gets 401, refresh succeeds: multipart retry reconstructs the body and succeeds once.
6. A refresh timeout/503 does not destroy credentials; a revoked refresh does.
7. Plan IDs with changed prices use API values and removed plans cannot be purchased from fallback data.
8. Withdrawal confirmation and serialized amount are exactly the same under the agreed currency contract.
9. Lost payment verification response stays pending and reconciles without double credit or double purchase.
10. Notification read-all rollback restores an accurate count even when a new event arrives meanwhile.
11. Accepted message plus lost REST response plus retry results in one server message and one visible bubble.
12. Pop each loading/uploading screen: no emit-after-close or late UI side effect.
13. Load 25 withdrawals, 51 favorites and 21 conversations: older entries remain accessible and totals stay correct.
14. Reject host profile save with success:false: the UI and cache must not claim success.

## Security testing that remains backend-dependent

No production endpoint was probed or load-tested. These tests should use test identities and isolated staging data; the absence of backend code prevents a conclusion today.

| Security boundary | Required test |
|---|---|
| Object ownership | With users A/B, attempt access to B's wallet, recharge/referral history, conversation, notification and call IDs through A's session; every protected read and write must enforce ownership |
| Role authorization | User must not request host withdrawals/earnings or alter host/admin fields; host cannot edit another host; frontend route checks are not authorization |
| OTP abuse | Server throttling per identity/device/IP, bounded attempts, expiration, one-time use, replay/concurrency and non-enumerating responses |
| Token/session lifecycle | Refresh rotation and replay detection, revocation, logout cookie contract, multi-device termination and stale socket credential rejection |
| Payment integrity | Verify signature on server using trusted order data, enforce user/order/amount/currency binding, deduplicate callbacks/webhooks and reject replay |
| Withdrawal integrity | Atomic balance reservation, minimum/precision policy, payout ownership, concurrent requests, idempotency and reconciliation of failed payouts |
| RTC authorization / billing | Tokens scoped to correct channel/participant/expiry; clients cannot activate/end/read another call; exactly-once debit under simultaneous endings |
| Chat and blocking | Conversation membership on reads/writes, server-side block enforcement, rate/size limits, clientMessageId deduplication, unread/read consistency |
| Media upload / KYC | Enforce MIME magic, size/dimensions, access control, retention, immutable verification evidence and metadata stripping; no unrestricted public object access |
| Input / error handling | Schema validation, injection-resistant database access, safe filters/sorts, no stack traces/secrets, bounded pagination and search complexity |
| Web if supported | Origin/CORS allowlists, cookie attributes, CSRF model, browser token storage, deep links and file upload adapter behavior |
| Infrastructure | Secrets/IAM, patching, database/network isolation, backups and restore, audit logging, incident response and retention |

These are verification requirements, not claims that the backend currently fails them.

## Performance and scalability assessment

**No latency, FPS, memory, battery or concurrency benchmark was measured.** The strongest source-level scaling problems are missing server pagination, full-roster work on every presence event, repeated build-time fetches and unbounded accumulated message/notification lists. Chat merges sort all retained messages, and delivery acknowledgment checks use list membership; these warrant measurement for large histories rather than premature optimization.

A client performance run should use physical representative devices in profile mode. Flutter recommends profiling release-like behavior and identifying actual expensive work; debug timing is not a production benchmark. See [Flutter performance guidance](https://docs.flutter.dev/perf/best-practices).

| Workload | Measure | Suggested acceptance approach |
|---|---|---|
| Cold start / authenticated resume | Time to usable first frame, session refresh and first content, errors | Establish budget separately for cold/warm and network class; do not hide network failures as successful zero states |
| Large host roster | CPU, allocation, frame time under 100/1000/10000 presence events | Confirm bounded visible work and smooth scrolling; batch snapshot bursts |
| Chat / notifications | 20/200/2000 messages, duplicate events, memory after leaving screen | Paginate, deduplicate, bound retained state; no request storm for repeated unknown-conversation pushes |
| Repeated navigation | 50 open/back cycles of profile/chat/wallet/online users | Socket remains valid, memory stabilizes, subscriptions/timers return to baseline |
| Calls | 30–60 minute audio/video, camera switching, background/foreground, reconnection | Measure battery/thermal/network/RTC quality and ensure all resources stop on every terminal path |
| Media upload | Small/large images, slow uplink, cancellation, 401 retry | Bound size/dimensions, timeouts, memory and completion; retry only safely reconstructable requests |
| Payment / withdrawal | Delayed/duplicated responses and process death | Correctness and reconciliation take precedence over perceived instant success |
| Backend | Agreed concurrency ramp and soak, socket fan-out, active calls and financial operations | Define p95/p99/error/resource budgets from product targets; measure database locks/indexes/queue depth and recovery |

The app's standard API configuration has 60-second connect and receive timeouts but no default send timeout, and caller cancellation is unused. These do not impose a total request deadline. Shorter call-end options improve one path, but refresh can still add its own delay. Establish per-operation budgets instead of applying one global timeout to all workloads.

## Dependencies and release updates

Version spot-checks below use `pubspec.lock` for installed versions and publisher package pages accessed on the audit date. Newer version availability is **not** evidence of a vulnerability, compatibility or a required blind upgrade. The full transitive Dart/native graph has not been matched against an advisory database. Searches for selected upstream advisory pages were inconclusive; this is not a clean security scan.

| Package | Locked | Publisher page version observed | Recommended review |
|---|---:|---:|---|
| Dio | 5.9.2 | [5.11.1](https://pub.dev/packages/dio) | Review migration/changelog, then retest auth concurrency, multipart retry, cancellation and timeout behavior |
| socket_io_client | 3.1.6 | [3.1.6](https://pub.dev/packages/socket_io_client) | Current page version matches lock; fix connection ownership/auth caching in app and test server compatibility |
| agora_rtc_engine | 6.5.4 | [6.6.4](https://pub.dev/packages/agora_rtc_engine) | Assess native SDK changes with device call/reconnect/token/teardown regression tests |
| flutter_secure_storage | 10.0.0 | [11.2.0](https://pub.dev/packages/flutter_secure_storage) | Major-version review; verify Android/iOS existing-token migration and failure behavior before adoption |
| permission_handler | 11.4.0 | [13.0.2](https://pub.dev/packages/permission_handler) | Major-version review; check minimum SDK/platform setup and denied/permanent-denial behavior |
| razorpay_flutter | 1.4.4 | [1.4.7](https://pub.dev/packages/razorpay_flutter) | Verify native dependency resolution, checkout lifecycle, return from external app and minified release callbacks |

Review all direct and transitive packages once `flutter pub outdated` and dependency/security tooling can run in a working environment. Capture an SBOM including resolved Gradle and CocoaPods dependencies, not just pub packages. Commit reproducible lockfiles and track the Flutter SDK version used by CI. The inspected Android Razorpay dependency uses a dynamic native version; pubspec.lock alone does not freeze that native artifact.

## Code health details

The machine-readable inventory includes all 24 import-unreachable candidates and 25 duplicate-block file groups. The scan follows literal Dart imports, exports and parts from main; it is a heuristic, not the Dart analyzer or proof that every symbol is dead. It does not infer reflection/generated registrations or account for alternative entrypoints unless reachable from main. Generated DI makes several otherwise unused layers appear reachable.

Examples worth reviewing:

- An old transition/animation family (`screen_transition_*`, metadata registry, animated wrappers) is disconnected from main's import graph.
- The old `video_call_online_contents`, summary and card widgets are disconnected; actual audio/video routes use HomeCubit/UserGrid. Their fake sample-user/empty-button behavior was therefore **not** counted as a live browsing defect.
- Several old analytics summary cards/models and the call-status-label widget are disconnected.
- ReportCallBottomSheet is disconnected but represents missing functionality, so it needs wiring rather than automatic removal.
- User/host chat thread/list/tile and support-sheet copies contain repeated code; consolidate only after documenting role-specific differences.
- The host-dashboard data source still returns hardcoded demo metrics and sleeps 600 ms. The current main dashboard widgets use live cached profile/presence and do not visibly consume all those metrics, so this was not reported as proof that users see fake earnings. Replace/remove the mock layer and artificial latency before future UI relies on it.
- Calls are concentrated in a 1469-line cubit and a 700-line socket service. Separate session lifecycle, transport, billing reconciliation and display formatting to make cancellation and identity ownership testable.

## Positive controls observed

These are source observations, not completed security tests:

- Access tokens are stored in memory; refresh and local auth information use secure storage.
- Token refresh attempts share an in-flight Future, reducing one class of refresh stampede.
- Auth headers are opt-in; public OTP routes do not automatically receive a stale bearer token.
- Android disables backup and release builds require release signing properties instead of silently falling back to a debug signing key.
- Android release shrinking is configured; native camera/microphone permissions are declared for Android/iOS.
- Payment order creation and verification call backend endpoints; the client is not itself credited merely because Razorpay's callback fires.
- API failures generally map through repository/use-case boundaries, and several call/model/auth regressions have meaningful unit tests.
- Call termination promptly leaves media locally; retry logic exists for server reconciliation. The remaining correctness problem is reconciling that asynchronous work with session identity and wallet refresh.
- Debug-only logging guards exist. Redaction still needs improvement, and logging guards should prevent expensive work before interpolation where relevant.
- HTTPS/WSS configuration was observed; leaving certificate pinning disabled on automatically-rotated hosting certificates is an explicit operational choice, not proof of insecure TLS.

## Recommended order of work

1. **Session and call correctness:** MT-01 through MT-06, MT-11/12. Add deterministic tests for account switching, delayed completions, shared socket ownership and multipart retries.
2. **Money and data accuracy:** MT-07 through MT-10, MT-16/17/19/29. Settle the currency, plan and payment-settlement API contracts before cosmetic changes.
3. **User safety and feature completion:** account deletion/support/notify-me, accessible call reporting, correct legal/consent behavior and immutable KYC handling.
4. **Resilience and scale:** pagination, deduplicated events, retry identity, cancellation, strict validation and bounded presence/message work.
5. **Release validation:** restore analyzer/tests, establish CI, run real-device acceptance on agreed targets, then dependency/native upgrade and signed-release tests.

For the next audit phase, the missing inputs are the intended platforms, a working Flutter execution environment, authorized staging accounts (user and host), backend source or current API contract, and expected concurrency/service targets. Until then, backend security, end-to-end behavior, measured performance and release builds remain open.

## Final integrity record

The final check compared 637 existing files under lib/test with their initial SHA-256 hashes: no original file contents changed. Git status is unchanged, preserving the initial 18 modified tracked files and three untracked entries. Two Finder `.DS_Store` metadata files appeared under lib/test during the audit; they are recorded separately and are not application source changes. The auditor issued no write commands against the project. Reviewed HEAD: `e69cd6bdd583ce3924f9766444cb86fe7a394ca4`, plus the existing working-tree changes.

Deliverables: this report, `findings.json`, `audit-inventory.json`, `verification-record.json`, and the two raw runtime-error logs. No source files, secrets or environment configurations are bundled in these deliverables.
