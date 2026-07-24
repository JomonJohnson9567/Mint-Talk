# Product Requirements Document
## Mint Talk — Week 3: Calls, Billing, Earnings & Messaging Module
### Flutter Client Implementation Specification (Dart + BLoC)

| Field | Value |
|---|---|
| Document Owner | Frontend (Flutter) Team |
| Source | Mint Talk Week 3 API Integration Guide (Confidential) |
| Base URL | `https://mint-talk-backend.onrender.com/api/v1` |
| WebSocket URL | `ws://<domain>` (e.g. `ws://localhost:5000` locally / `wss://mint-talk-backend.onrender.com` in production) |
| State Management | `flutter_bloc` (BLoC / Cubit pattern) |
| Status | Draft v1.0 |
| Known Exclusion | W3-06 (Call Recording URL Handling) is excluded/pending — not covered by this PRD |

---

## 1. Purpose & Scope

This PRD translates the Week 3 backend API contract — Socket.IO presence/connection management, the Call Lifecycle (Agora-based), per-minute billing, host earnings, and direct messaging/chat — into a concrete Flutter implementation plan. It defines required BLoCs, data contracts, real-time event handling, role-based UI behavior, and acceptance criteria.

**In scope:**
- Socket.IO connection lifecycle, presence, heartbeat, and single-device session enforcement
- Full call lifecycle: initiate, accept, activate, reject, cancel, end, fetch/history
- Client-side representation of per-minute billing effects (balance depletion, forced termination)
- Host earnings ledger and admin earnings audit
- Direct messaging: send, list conversations, message history, read receipts, delivery acknowledgment

**Out of scope:**
- Call recording URL handling (W3-06, explicitly excluded/pending on backend)
- Agora SDK low-level media configuration (only the join contract — `userAccount = userId` — is specified)
- Week 4 host onboarding/admin review flows (covered in a separate PRD)

---

## 2. Roles Recap & Feature Access

This module is primarily role-agnostic for calling/messaging (any authenticated user can call, be called, and chat), with specific role gates below.

| Feature | client (caller) | staff (host) | admin / super_admin |
|---|:---:|:---:|:---:|
| Initiate a call | ✅ | ✅ (can call other hosts as a caller) | ❌ (not applicable) |
| Accept / Reject a call | ❌ | ✅ | ❌ |
| Activate / End / Cancel a call | ✅ (as caller) | ✅ (as host) | ❌ |
| View own earnings ledger | ❌ | ✅ | ❌ |
| Audit all host earnings | ❌ | ❌ | ✅ |
| Send/receive messages | ✅ | ✅ | ✅ (support use cases) |
| Emit `update_availability` | ❌ | ✅ | ❌ |

Role is sourced from the shared `AuthBloc` (see companion Week 4 PRD) and must gate the earnings-audit screen and the host-only availability controls.

---

## 3. Recommended Architecture

### 3.1 Layered structure

```
lib/
 ├─ core/
 │   ├─ network/            # Dio client, interceptors, error mapper
 │   ├─ socket/              # SocketService (socket_io_client wrapper)
 │   ├─ agora/               # AgoraService wrapper (join/leave channel)
 │   └─ storage/             # secure token storage
 ├─ features/
 │   ├─ presence/            # connection state, presence, session_terminated handling
 │   ├─ calling/
 │   │   ├─ data/            # models, remote data source, repository impl
 │   │   ├─ domain/
 │   │   └─ presentation/    # CallBloc, incoming-call UI, in-call UI, history
 │   ├─ earnings/
 │   │   ├─ host_ledger/
 │   │   └─ admin_audit/
 │   └─ messaging/
 │       ├─ conversations/
 │       └─ chat_thread/
 └─ shared/
     └─ widgets/
```

### 3.2 Networking

- **HTTP client:** `dio`, base URL as above, `Authorization: Bearer <JWT>` attached by an interceptor on every request in this module.
- **Content-Type:** `application/json`.
- **Error mapping:** uniform `Failure` types consumed by every Bloc (`ServerFailure`, `ValidationFailure`, `UnauthorizedFailure`, `InsufficientBalanceFailure`, `NetworkFailure`).

### 3.3 Real-time layer (`SocketService`)

- **Package:** `socket_io_client`.
- Connects passing JWT via `auth: { token: <JWT> }` (preferred per this doc's connection example) with a fallback of the `Authorization` header, matching backend's stated dual support.
- **Heartbeat:** the service must keep the socket alive with the server's 30-second heartbeat cadence (library-level ping/pong is generally automatic with `socket_io_client`, but the app must not put the socket to sleep in background beyond what the OS allows, especially on iOS — see §8).
- **Grace period:** if the socket disconnects during an active call, the UI must NOT immediately end the call locally — the backend allows a 15-second reconnect grace window before ending the call server-side. Show a "Reconnecting…" overlay on the in-call screen during this window rather than navigating away.
- **Single device enforcement:** on receiving `session_terminated`, the app must immediately: stop all active call/chat state, show a "Logged in on another device" dialog, clear tokens, and route to login. This is a global listener, same pattern as the Week 4 `host_application_approved` handling.

---

## 4. Data Models (Dart)

All models are immutable, `Equatable`-based, with `fromJson`/`toJson`.

### 4.1 `CallSession`
```dart
class CallSession extends Equatable {
  final String callId;
  final String? agoraChannel;
  final String? agoraToken;
  final CallStatus status; // ringing | accepted | active | ended | rejected | missed | insufficient_balance
  final CallType callType; // audio | video
  final DateTime? activeAt;
  final int? durationSeconds;
  final int? billedMinutes;
  final int? totalPointsDebited;
  final String? endReason;
  // caller_ended_call | host_ended_call | user_disconnected |
  // insufficient_balance | host_rejected | caller_cancelled_before_answer
}

enum CallStatus { ringing, accepted, active, ended, rejected, missed, insufficientBalance }
enum CallType { audio, video }
```

### 4.2 `IncomingCallPayload`
```dart
class IncomingCallPayload extends Equatable {
  final String callId;
  final String callerId;
  final String callerName;
  final String hostId;
  final CallType callType;
  final String agoraChannel; // per doc field prefix "ag..." — confirm exact key with backend
}
```

### 4.3 `EarningEntry` / `EarningsSummary`
```dart
class EarningsSummary extends Equatable {
  final double totalGrossINR;
  final double totalCommissionINR;
  final double totalTdsINR;
  final double totalNetINR;
  final int totalBilledPoints;
  final int totalCalls;
}

class EarningEntry extends Equatable {
  final String callId;
  final int billedPoints;
  final double grossEarningINR;
  final double platformCommissionINR;
  final double taxDeductedINR;
  final double netEarningINR;
  final DateTime createdAt;
}
```

### 4.4 `ChatMessage` / `Conversation`
```dart
class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String recipientId;
  final String content;
  final MessageStatus status; // sent | delivered | read
  final DateTime createdAt;
}

enum MessageStatus { sent, delivered, read }

class Conversation extends Equatable {
  final String id;
  final String lastMessagePreview;
  final DateTime lastActivityAt;
  final int unreadCount;
  // + participant summary fields as needed by list UI
}
```

---

## 5. Feature Specifications

---

### 5.1 Socket.IO Connection & Presence

**Ref:** W3-04

**Bloc:** `PresenceBloc` (app-lifecycle scoped, initialized once after login)

**Responsibilities:**
- Establish/tear down socket connection tied to `AuthBloc` authenticated state.
- Send heartbeat implicitly via the socket.io client's built-in ping.
- Listen for and re-broadcast into app-wide state: `presence_update`, `host_status_update`, `session_terminated`.
- Expose `subscribeToCall(callId)` / `unsubscribeFromCall(callId)` wrappers around the `subscribe_call` / `unsubscribe_call` outgoing events, used by the Calling feature whenever a call screen mounts/unmounts.

**Events:**
```dart
ConnectSocket
DisconnectSocket
SubscribeToCall(String callId)
UnsubscribeFromCall(String callId)
```

**States:**
```dart
SocketDisconnected
SocketConnecting
SocketConnected
SocketReconnecting        // drives "Reconnecting…" UI during the 15s grace window
SocketSessionTerminated    // triggers global logout flow
```

**UI requirements:**
- A persistent, unobtrusive connection-state indicator available to the Host Dashboard and in-call screens.
- `SocketSessionTerminated` triggers a blocking dialog ("You've been logged in on another device") with a single OK button that clears session and routes to login — cannot be dismissed by back button.

---

### 5.2 Call Lifecycle

**Ref:** W3-01. All Agora channel joins use the user's `userId` string as the Agora `userAccount`, **not** a numeric UID — this must be enforced in the `AgoraService` wrapper.

**Bloc:** `CallBloc` (one live instance per active call session)

#### 5.2.1 Initiate Call (Caller)
`POST /calls/initiate` — body: `{ hostId, callType }`

```dart
InitiateCall({required String hostId, required CallType callType})
```
```dart
CallInitiating
CallRinging(CallSession session)       // 201, status "ringing"
CallInitiateFailure(String message)     // e.g. host unavailable, insufficient balance for 1 min
```
**UI:** Outgoing call screen shows ringing state, target host name/avatar, and a Cancel button (wired to §5.2.5). Balance/availability failures surface a clear, actionable message (e.g., "Add points to continue" CTA to wallet top-up if the failure is balance-related).

#### 5.2.2 Accept Call (Host)
`POST /calls/:callId/accept`

Triggered from the `incoming_call` socket event UI (full-screen incoming call card with Accept/Reject), only rendered for the target host.
```dart
AcceptCall(String callId)
```
```dart
CallAccepting
CallAccepted(CallSession session)   // status "accepted"
CallAcceptFailure(String message)
```

#### 5.2.3 Activate Call (Caller or Host)
`POST /calls/:callId/activate` — **must be called exactly once Agora media begins streaming successfully**, since this triggers the billing worker.
```dart
ActivateCall(String callId)
```
```dart
CallActivating
CallActive(CallSession session)     // status "active"; starts local call timer UI
CallActivateFailure(String message)
```
**UI requirement:** Do not call `activate` on Agora "joining" — only on confirmed media flow (e.g., Agora's `onJoinChannelSuccess` / first remote frame per platform capability), to avoid billing before media truly starts.

#### 5.2.4 Reject Call (Host)
`POST /calls/:callId/reject`
```dart
RejectCall(String callId)
```
```dart
CallRejected(CallSession session)   // status "rejected", endReason "host_rejected"
```
**UI:** dismisses incoming-call screen for host; caller's `CallBloc` should reflect the terminal state (via socket or by polling `GET /calls/:callId` if no explicit event is documented for the caller side — flag to backend if a dedicated event is needed).

#### 5.2.5 Cancel Call (Caller)
`POST /calls/:callId/cancel` — used before the host answers.
```dart
CancelCall(String callId)
```
```dart
CallCancelled(CallSession session)  // status "missed", endReason "caller_cancelled_before_answer"
```

#### 5.2.6 End Call (Caller or Host)
`POST /calls/:callId/end`
```dart
EndCall(String callId)
```
```dart
CallEnding
CallEnded(CallSession session)
// duration (seconds), billedMinutes (rounded up), totalPointsDebited, endReason
CallEndFailure(String message)
```
**UI requirement:** Post-call summary screen must display duration, billed minutes, and points debited exactly as returned (do not recompute client-side — server is source of truth). If `endReason == "insufficient_balance"`, show a distinct "Call ended — you ran out of points" message rather than the generic end-call summary, and prompt wallet top-up.

#### 5.2.7 Fetch Call Data
| Purpose | Method | Endpoint |
|---|---|---|
| Single call details | GET | `/calls/:callId` |
| Call history | GET | `/calls/history?status=&page=&limit=` |

**Bloc:** `CallHistoryBloc` (paginated list pattern, filterable by `status`)
```dart
FetchCallHistory({status, page})
LoadMoreCallHistory
```
```dart
CallHistoryLoading / Loaded(items, hasMore) / LoadingMore / Error
```
**UI:** Call history list with status filter chips, each row showing call type icon, counterpart name, duration, points debited, and timestamp; tapping opens call detail (via `GET /calls/:callId`).

---

### 5.3 Billing Behavior (Client-Side Implications)

**Ref:** W3-02. No dedicated client-callable endpoint beyond `/activate` and `/end` — this section defines **UI behavior driven by billing side-effects**, not a new Bloc.

| Backend Behavior | Required Client Behavior |
|---|---|
| Billing starts on `/activate` | Start an in-call timer the moment `CallActive` state is reached |
| Minutes rounded up (e.g. 125s → 3 min in the example) | Do not display a client-computed "billed minutes so far" as authoritative — show elapsed real-time duration during the call, and only show official `billedMinutes` from the `/end` response afterward |
| Points depleted mid-call → backend terminates call, sets `insufficient_balance`, "emits a disconnect alert to both parties" | `CallBloc` must listen for this termination signal (via socket disconnect alert or forced `/end` response) and immediately show the insufficient-balance end screen (§5.2.6) to both caller and host, tearing down the Agora session |
| Balance check happens at `/initiate` for at least 1 minute | Surface pre-call balance warnings if the local wallet balance display is already known to be low, before even attempting `/initiate`, to reduce failed-call friction (optimistic UX, not a backend requirement) |

**Note:** the exact socket event name for the "disconnect alert" on insufficient balance is not explicitly named in this API guide (only described narratively). Flag with backend to confirm whether it rides on an existing event or requires a new one before implementation; in the interim, treat any forced `/end` response with `endReason: "insufficient_balance"` as the authoritative signal.

---

### 5.4 Host Earnings

**Ref:** W3-03. Fixed platform configuration (display-only reference, not client-configurable):

| Constant | Value |
|---|---|
| `POINT_TO_INR_RATE` | ₹0.50 per point |
| `PLATFORM_COMMISSION_RATE` | 30% |
| `TDS_RATE` | 10% |
| Net formula | Gross − Commission − TDS |

#### 5.4.1 Host: My Earnings Ledger
`GET /earnings/my-ledger` — role: `staff`

**Bloc:** `HostEarningsBloc`
```dart
FetchMyEarnings
```
```dart
EarningsLoading
EarningsLoaded(EarningsSummary summary, List<EarningEntry> earnings)
EarningsError(String message)
```
**UI requirements:**
- Summary card at top: total gross, commission, TDS, net (all INR), total billed points, total calls.
- Below: per-call ledger list, each row showing `callId`-linked date, billed points, gross/commission/TDS/net breakdown (expandable row or detail sheet).
- All monetary values formatted as currency (₹) with 2 decimal places, matching backend's numeric precision.

#### 5.4.2 Admin: Audit All Host Earnings
`GET /earnings/admin/audit` — role: `admin` / `super_admin` only, paginated.

**Bloc:** `AdminEarningsAuditBloc` (paginated list pattern, same shape as §5.6 in the Week 4 PRD)
```dart
FetchEarningsAudit({page, limit})
LoadMoreEarningsAudit
```
```dart
AuditLoading / Loaded(items, hasMore) / LoadingMore / Error
```
**UI:** Admin-only screen, per-host breakdown table/list; route-guarded identically to other admin screens.

---

### 5.5 Messaging & Chat

**Ref:** W3-05. All endpoints require a valid user JWT (any authenticated role).

#### 5.5.1 Send Direct Message
`POST /chats/messages` — body: `{ recipientId, content }`

**Bloc:** `ChatThreadBloc` (scoped per open conversation)
```dart
SendMessage({required String recipientId, required String content})
```
```dart
MessageSending
MessageSent(ChatMessage message)   // status "sent"
MessageSendFailure(String message)
```
**UI:** Standard chat composer; optimistically render the message with a "sending" indicator, replace with server-confirmed message (and real `_id`/timestamp) on success, mark failed with a retry affordance on failure.

#### 5.5.2 List Conversations
`GET /chats/conversations` — paginated, sorted by latest activity.

**Bloc:** `ConversationsListBloc`
```dart
FetchConversations({page})
LoadMoreConversations
```
```dart
ConversationsLoading / Loaded(items, hasMore) / LoadingMore / Error
```
**UI:** Inbox-style list, most recent activity first, unread badge count per conversation.

#### 5.5.3 Get Message History
`GET /chats/conversations/:conversationId/messages?page=&limit=`

**Bloc:** part of `ChatThreadBloc`
```dart
FetchMessageHistory({required String conversationId, page})
LoadOlderMessages
```
```dart
MessagesLoading / Loaded(messages, hasMore) / LoadingOlder / Error
```
**UI:** Reverse-chronological infinite scroll (load older on scroll-up), standard chat bubble UI distinguishing sent vs. received, with status ticks (sent/delivered/read) on the sender's own messages only.

#### 5.5.4 Mark Conversation as Read
`POST /chats/conversations/:conversationId/read`

```dart
MarkConversationRead(String conversationId)
```
**UI/behavior:** Fire automatically when a chat thread screen is opened/foregrounded (and messages are visible), and update the conversation's unread badge to zero immediately (optimistic) in the Conversations list.

#### 5.5.5 Delivery Acknowledgment
`POST /chats/messages/delivered` — body: `{ messageIds: [...] }`

```dart
AcknowledgeDelivered(List<String> messageIds)
```
**Behavior:** Fired automatically by the receiving client as soon as new messages arrive via socket/poll while the app is foregrounded, to flip status `sent → delivered`. This is a background/fire-and-forget action, not user-triggered — batch message IDs received in a short window rather than firing one call per message.

---

## 6. Socket.IO Event Reference Summary

| Direction | Event | Payload / Notes | Consumed by |
|---|---|---|---|
| Client → Server | `update_availability` | `{ audio_available, video_available }` — host only | `PresenceBloc` (staff only) |
| Client → Server | `subscribe_call` | `{ callId }` | `CallBloc` on call screen mount |
| Client → Server | `unsubscribe_call` | `{ callId }` | `CallBloc` on call screen unmount |
| Server → Client | `presence_update` | Any user's presence status changed | `PresenceBloc` |
| Server → Client | `host_status_update` | A host's audio/video availability toggled | `PresenceBloc` / host-browsing screens |
| Server → Client | `incoming_call` | `callId, callerId, callerName, hostId, callType, agoraChannel/token` | `CallBloc`, target host only — renders full-screen incoming call UI |
| Server → Client | `call_accepted` | `callId, agoraChannel` | `CallBloc`, caller only — transitions caller out of ringing state into join-channel flow |
| Server → Client | `session_terminated` | Old socket receives this on new-device login | Global `PresenceBloc` listener → forced logout |

---

## 7. Error Handling & Edge Cases

- **401/403:** consistent with the Week 4 module — global logout + redirect to login.
- **Call-specific failures:** `/initiate` failures (host unavailable, insufficient balance) must show distinct, actionable messages rather than a generic error toast.
- **Reconnect grace window:** during the 15-second reconnect grace period on socket drop mid-call, do not tear down the Agora session or navigate away; only do so if reconnection fails past the window or the server sends a terminal call state.
- **Duplicate `activate` calls:** guard `CallBloc` so `/activate` is only ever invoked once per call session (idempotency should also exist server-side, but avoid redundant calls from race conditions between caller/host clients).
- **Stale incoming-call UI:** if `incoming_call` UI is showing and the call is cancelled by the caller (§5.2.5) before the host acts, the host's screen must be dismissed automatically (via socket or by polling call status) rather than left showing a stale ringing card.
- **Message send retry:** failed message sends must be retryable without duplicating the message (use a client-generated temp ID to dedupe against the eventual server-confirmed message).

---

## 8. Non-Functional Requirements

| Requirement | Detail |
|---|---|
| State management | `flutter_bloc` exclusively; no `setState`-driven business logic |
| Testability | Every Bloc/Cubit unit-tested (success, validation-failure, server-failure) via `bloc_test` |
| Background/foreground handling | Socket connection and Agora session lifecycle must correctly handle iOS/Android background suspension (e.g., CallKit/ConnectionService integration for incoming calls) — flag as a platform-specific spike if not already covered elsewhere |
| Precision | Monetary values (INR) rendered with exactly 2 decimal places, matching backend's numeric output |
| Real-time responsiveness | In-call timer and connection-state indicators must update without perceptible lag (target < 500ms from socket event to UI update) |
| Security | JWT stored via `flutter_secure_storage`; Agora tokens never logged in plaintext |
| Localization | All user-facing strings (call status labels, end reasons, message statuses) routed through the app's i18n layer |

---

## 9. API Quick Reference (for implementation checklist)

| Method | Endpoint | Role | Feature Section |
|---|---|---|---|
| (socket) | `update_availability` | staff | §5.1 |
| (socket) | `subscribe_call` / `unsubscribe_call` | any | §5.1 |
| POST | `/calls/initiate` | client (as caller) | §5.2.1 |
| POST | `/calls/:callId/accept` | staff (as host) | §5.2.2 |
| POST | `/calls/:callId/activate` | caller or host | §5.2.3 |
| POST | `/calls/:callId/reject` | staff (as host) | §5.2.4 |
| POST | `/calls/:callId/cancel` | client (as caller) | §5.2.5 |
| POST | `/calls/:callId/end` | caller or host | §5.2.6 |
| GET | `/calls/:callId` | caller or host | §5.2.7 |
| GET | `/calls/history` | any | §5.2.7 |
| GET | `/earnings/my-ledger` | staff | §5.4.1 |
| GET | `/earnings/admin/audit` | admin/super_admin | §5.4.2 |
| POST | `/chats/messages` | any | §5.5.1 |
| GET | `/chats/conversations` | any | §5.5.2 |
| GET | `/chats/conversations/:conversationId/messages` | any | §5.5.3 |
| POST | `/chats/conversations/:conversationId/read` | any | §5.5.4 |
| POST | `/chats/messages/delivered` | any | §5.5.5 |
| (socket) | `presence_update`, `host_status_update`, `incoming_call`, `call_accepted`, `session_terminated` | server → client | §6 |

---

## 10. Acceptance Criteria Summary

- [ ] Socket connects on login with JWT, reconnects automatically, and enforces single-device logout via `session_terminated`.
- [ ] Full call lifecycle (initiate → accept → activate → end) works end-to-end for both audio and video, with Agora `userAccount` set to `userId`.
- [ ] Reject/cancel flows correctly set terminal states (`rejected` / `missed`) with zero billing, matching backend response exactly.
- [ ] In-call timer starts only after `CallActive`, and the post-call summary shows server-authoritative `duration`, `billedMinutes`, `totalPointsDebited`.
- [ ] Insufficient-balance mid-call termination is handled distinctly from a normal end-call, on both caller and host sides.
- [ ] Host earnings ledger displays summary + per-call breakdown with correct INR formatting; admin audit screen is role-gated.
- [ ] Chat: send, list conversations, paginated history, mark-as-read, and delivery acknowledgment all function with optimistic UI and correct status tick progression (sent → delivered → read).
- [ ] 15-second reconnect grace window is respected in-call before any local call teardown.
- [ ] All Bloc states are unit-tested; no business logic lives in widgets.

---

## 11. First-Release Implementation Decisions

The following decisions override broader or ambiguous statements elsewhere in
this draft for the current Flutter application release.

### 11.1 Scope

- The application has two authenticated roles only: `client` and `staff`.
- Only clients initiate calls. Staff can accept, reject, and end calls but
  cannot initiate calls.
- Incoming calls are foreground-only. Background and terminated-app incoming
  calls are excluded.
- The existing dummy host list and dummy call logs remain until their API
  response contracts are supplied.
- Host earnings and targets are deferred.

### 11.2 Host pricing and availability

- Hosts set `audioRate` and `videoRate` in virtual points per minute using
  `PATCH /hosts/preferences`; each rate is bounded to 1–1000.
- A host starts offline whenever the app is opened or resumed and must select
  Audio, Video, or Both and tap Go Live.
- After the preferences PATCH succeeds, the app emits `update_availability`.
- Going offline emits both availability values as `false` without clearing the
  saved rates.
- `host_status_update` uses this payload:

```json
{
  "hostId": "650b4a...",
  "audio_available": true,
  "video_available": false,
  "isOnline": true,
  "isOnCall": false,
  "audioRate": 60,
  "videoRate": 120
}
```

### 11.3 Call coordination

- Ringing lasts 30 seconds. The backend owns the authoritative timeout and the
  Flutter client mirrors it for UI. Timeout produces status `missed` with
  `endReason: ringing_timeout`.
- A host can have only one ringing or active call. Further initiation attempts
  fail with a `HOST_BUSY` error; Flutter does not maintain a call queue.
- The host joins Agora only after accepting and receiving the host RTC token.
- Only the caller invokes `/calls/:callId/activate`, after both the caller's
  local join and the remote host join are confirmed. The endpoint must be
  idempotent.
- Billing minutes are rounded up: `ceil(durationSeconds / 60)`. Therefore 125
  seconds is 3 billed minutes.
- The backend snapshots `ratePerMinute` on the call at initiation. Later host
  preference changes do not affect that call.
- Wallet balance is refreshed after an initiation failure, normal call end,
  insufficient-balance termination, and successful recharge.

The backend emits one authoritative event for call state changes:

```text
call_status_updated
```

```json
{
  "callId": "660d2b...",
  "status": "ended",
  "endReason": "host_ended_call",
  "duration": 125,
  "billedMinutes": 3,
  "totalPointsDebited": 180,
  "ratePerMinute": 60,
  "updatedAt": "2026-06-05T12:10:00.000Z"
}
```

Non-applicable terminal fields may be absent before a call ends. The event
covers `accepted`, `active`, `rejected`, `missed`, `ended`, and
`insufficient_balance` transitions.

### 11.4 Agora configuration

- `AGORA_APP_ID` is environment-driven. The placeholder
  `replace_with_agora_app_id` deliberately fails configuration validation and
  must be replaced with the real 32-character Agora App ID.
- Agora channel names and RTC tokens are never hardcoded; they come from
  `/calls/initiate` for the caller and `/calls/:callId/accept` for the host.
- Both participants join with their authenticated `userId` string as the Agora
  `userAccount`.

### 11.5 Messaging

- Clients can send only the fixed messages exposed by the user UI to currently
  available staff.
- Staff see messages in a read-only Notifications screen and cannot reply.
- Notifications are fetch-only for this release; no `new_message` socket event
  or real-time badge is required.
- Conversation/history parsing will be finalized when the backend response
  envelopes are supplied.
