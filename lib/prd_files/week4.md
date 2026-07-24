# Product Requirements Document
## Mint Talk — Week 4: Staff (Host) Module
### Flutter Client Implementation Specification (Dart + BLoC)

| Field | Value |
|---|---|
| Document Owner | Frontend (Flutter) Team |
| Source | Mint Talk Week 4 Backend API Documentation (Confidential) |
| Base URL | `https://mint-talk-backend.onrender.com/api/v1` |
| WebSocket URL | `wss://mint-talk-backend.onrender.com` |
| State Management | `flutter_bloc` (BLoC / Cubit pattern) |
| Status | Draft v1.0 |

---

## 1. Purpose & Scope

This PRD translates the Week 4 backend API contract (Host Onboarding, KYC, Preferences, Admin Review, Target Milestones, and Socket.IO real-time events) into a concrete implementation plan for the Flutter application. It defines the required screens, BLoC architecture, role-based UI behavior, data contracts, and acceptance criteria needed for engineering to build this module without ambiguity.

**In scope:**
- Client → Host application flow (apply, KYC upload, status tracking)
- Host (staff) preferences, pricing, availability, and target tracking
- Admin review flow (list, approve, reject applications; assign milestones)
- Real-time Socket.IO events driving UI state changes
- Role-based navigation and screen/widget visibility across `client`, `staff`, `admin`, `super_admin`

**Out of scope:**
- Call/session UI itself (only the `POST /calls/:callId/end` trigger effect on targets is referenced)
- Payment/wallet UI details beyond wallet initialization side-effect
- Authentication/OTP login screens (referenced only as a redirect target)

---

## 2. Roles & Permission Matrix

| Role | Description | Assigned |
|---|---|---|
| `client` | Default role for all registered callers | On signup |
| `staff` | Approved host with dashboard access | After admin approval |
| `admin` | Reviews applications & milestones | Backend-assigned |
| `super_admin` | Full management access | Backend-assigned |

### 2.1 Screen/Feature Access Matrix

| Feature | client | staff | admin | super_admin |
|---|:---:|:---:|:---:|:---:|
| Apply to become a host | ✅ | ❌ (already staff) | ❌ | ❌ |
| Upload KYC documents | ✅ | ❌ | ❌ | ❌ |
| View own application status | ✅ | ✅ | ❌ | ❌ |
| Host dashboard (preferences, pricing) | ❌ | ✅ | ❌ | ❌ |
| Toggle audio/video availability | ❌ | ✅ | ❌ | ❌ |
| View own target milestones | ❌ | ✅ | ❌ | ❌ |
| View all host applications | ❌ | ❌ | ✅ | ✅ |
| Approve / reject applications | ❌ | ❌ | ✅ | ✅ |
| Assign target milestones | ❌ | ❌ | ✅ | ✅ |

The app **must gate routes and widgets by role**, not just hide buttons — a `staff`-only Bloc/Cubit must never be instantiated for a `client` session, and vice versa. Role is read from the decoded JWT / `AuthBloc` state after login and re-evaluated on every `host_application_approved` event (see §6.1) since role changes mid-session without a fresh login.

---

## 3. Recommended Architecture

### 3.1 Layered structure

```
lib/
 ├─ core/
 │   ├─ network/          # Dio client, interceptors, error mapper
 │   ├─ socket/            # SocketService (socket_io_client wrapper)
 │   ├─ storage/           # secure token storage
 │   └─ errors/            # Failure classes, exception mapping
 ├─ features/
 │   ├─ host_onboarding/
 │   │   ├─ data/          # models, remote data source, repository impl
 │   │   ├─ domain/        # entities, repository interface, use cases
 │   │   └─ presentation/  # bloc, screens, widgets
 │   ├─ host_dashboard/
 │   │   ├─ preferences/
 │   │   └─ availability/
 │   ├─ host_targets/
 │   └─ admin/
 │       ├─ applications_review/
 │       └─ milestone_assignment/
 └─ shared/
     ├─ widgets/
     └─ role_guard/         # RoleGuard widget + RouteGuard
```

### 3.2 Networking

- **HTTP client:** `dio` with a base `BaseOptions(baseUrl: ...)`.
- **Auth interceptor:** attaches `Authorization: Bearer <JWT>` from secure storage to every request except public endpoints. All endpoints in this module are protected.
- **Content-Type:** `application/json` for all POST/PATCH.
- **Error mapping:** a `DioException` → `Failure` mapper (`ServerFailure`, `ValidationFailure`, `UnauthorizedFailure`, `NetworkFailure`) consumed uniformly by every Bloc's error state.

### 3.3 Real-time layer

- **Package:** `socket_io_client`.
- **`SocketService`** is a singleton initialized after login, connecting to `wss://mint-talk-backend.onrender.com` and passing the JWT as the `auth` parameter on connection (not as a header).
- Exposes a `Stream` per event name that Blocs subscribe to via `StreamSubscription`, so UI state updates are pushed through the same BLoC pipeline as HTTP responses (no direct socket → widget calls).
- Socket must reconnect with the refreshed JWT if the token rotates (e.g., after the forced re-login on approval — see §6.1).

---

## 4. Data Models (Dart)

All models are immutable, use `Equatable` for Bloc state comparisons, and provide `fromJson` / `toJson`.

### 4.1 `HostApplication`
```dart
class HostApplication extends Equatable {
  final String id;
  final String userId;
  final String bio;
  final String? voiceSampleUrl;
  final String? videoSampleUrl;
  final ApplicationStatus status; // pending | approved | rejected
  final String? rejectionReason;
  final KycInfo? kyc;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum ApplicationStatus { pending, approved, rejected }
```

### 4.2 `KycInfo`
```dart
class KycInfo extends Equatable {
  final DocumentType documentType; // aadhar | pan | passport | voter_id
  final String documentNumber;
  final String frontPageUrl;
  final String? backPageUrl;
  final String? selfieUrl;
  final String status;
}

enum DocumentType { aadhar, pan, passport, voterId }
```

### 4.3 `HostPreferences`
```dart
class HostPreferences extends Equatable {
  final int? audioRate;   // 1–1000
  final int? videoRate;   // 1–1000
  final bool? isAudioAllowed;
  final bool? isVideoAllowed;
}
```

### 4.4 `HostTarget`
```dart
class HostTarget extends Equatable {
  final String id;
  final String hostId;
  final TargetPeriod period; // weekly | monthly
  final DateTime startDate;
  final DateTime endDate;
  final TargetType targetType; // call_minutes | points_earned | total_calls
  final num targetValue;
  final num currentValue;
  final TargetStatus status; // in_progress | achieved
}
```

### 4.5 `HostApplicationSummary` (admin list item)
```dart
class HostApplicationSummary extends Equatable {
  final String id;
  final String userId;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final String bio;
  final ApplicationStatus status;
}
```

---

## 5. Feature Specifications

Each feature below lists: endpoint(s), Bloc, events, states, and UI requirements.

---

### 5.1 Feature: Apply to Become a Host

**Endpoint:** `POST /host-applications/apply` — role: `client`

**Validation (client-side mirrors backend):**
| Field | Rule |
|---|---|
| `bio` | Required, 10–1000 chars |
| `voiceSampleUrl` | Optional, valid URL |
| `videoSampleUrl` | Optional, valid URL |

**Bloc:** `HostApplicationBloc`

**Events:**
```dart
class SubmitHostApplication extends HostApplicationEvent {
  final String bio;
  final String? voiceSampleUrl;
  final String? videoSampleUrl;
}
```

**States:**
```dart
HostApplicationInitial
HostApplicationSubmitting
HostApplicationSubmitSuccess(HostApplication data)
HostApplicationSubmitFailure(String message)
```

**UI requirements:**
- Form screen with bio textarea (live char counter, 10–1000), optional file/link pickers for voice & video samples.
- Submit button disabled until validation passes; shows loading spinner during `Submitting`.
- On success, navigate to KYC upload screen (Step 2) automatically.
- Only reachable from a "Become a Host" entry point visible **only** to users with role `client`.

---

### 5.2 Feature: Upload KYC Documents

**Endpoint:** `POST /host-applications/kyc` — role: `client`, must follow §5.1.

**Validation:**
| Field | Rule |
|---|---|
| `documentType` | Required, enum: aadhar / pan / passport / voter_id |
| `documentNumber` | Required, min 3 chars |
| `frontPageUrl` | Required, valid URL |
| `backPageUrl` | Optional |
| `selfieUrl` | Optional |

**Bloc:** Extend `HostApplicationBloc` with:
```dart
class SubmitKycDocuments extends HostApplicationEvent {
  final DocumentType documentType;
  final String documentNumber;
  final String frontPageUrl;
  final String? backPageUrl;
  final String? selfieUrl;
}
```
```dart
KycSubmitting
KycSubmitSuccess(HostApplication data)
KycSubmitFailure(String message)
```

**UI requirements:**
- Document type dropdown (4 options), document number field, front/back/selfie image upload widgets (upload to storage first, pass resulting URL).
- Front page image is mandatory before enabling submit.
- On success, transition user to the "Application Under Review" status screen (§5.3).

---

### 5.3 Feature: My Onboarding Status

**Endpoint:** `GET /host-applications/my-status` — role: `client` or `staff`

**Bloc:** `HostStatusCubit`

**States:**
```dart
HostStatusLoading
HostStatusLoaded(HostApplication application)
HostStatusNotFound        // user has never applied
HostStatusError(String message)
```

**UI requirements:**
- Status badge: `pending` (amber, "Under Review"), `approved` (green), `rejected` (red, shows `rejectionReason`).
- If `rejected`, show a "Edit & Resubmit" CTA that routes back to §5.1 pre-filled with prior values.
- This screen should also be updated reactively when the `host_application_approved` / `host_application_rejected` socket events fire (§6), not only on manual refresh/pull-to-refresh.

---

### 5.4 Feature: Host Preferences & Pricing

**Endpoint:** `PATCH /hosts/preferences` — role: `staff`

**Validation:**
| Field | Rule |
|---|---|
| `audioRate` | Optional, 1–1000 |
| `videoRate` | Optional, 1–1000 |
| `isAudioAllowed` | Optional, boolean |
| `isVideoAllowed` | Optional, boolean |

**Bloc:** `HostPreferencesBloc`

**Events / States:**
```dart
LoadHostPreferences
UpdateHostPreferences({audioRate, videoRate, isAudioAllowed, isVideoAllowed})
```
```dart
PreferencesLoading
PreferencesLoaded(HostPreferences prefs)
PreferencesUpdating
PreferencesUpdateSuccess(HostPreferences prefs)
PreferencesUpdateFailure(String message)
```

**UI requirements:**
- Sliders/steppers for `audioRate` and `videoRate` (bounded 1–1000, points unit).
- Toggle switches for `isAudioAllowed` / `isVideoAllowed`.
- Send only changed (non-null) fields in the PATCH payload — do not resend unmodified fields as null in a way that overwrites server values (confirm payload only includes touched keys).
- Screen only reachable when role == `staff`; must be part of the Host Dashboard shell.

---

### 5.5 Feature: Online Availability (Socket.IO, host-initiated)

**Event:** `update_availability` (Client → Server), role: `staff`

**Payload:**
```dart
{ "audio_available": bool, "video_available": bool }
```

**Bloc:** `HostAvailabilityCubit` (wraps `SocketService`)

**UI requirements:**
- A single "Go Online / Go Offline" master toggle plus independent Audio/Video availability toggles on the Host Dashboard.
- Emits `update_availability` on toggle change; does not wait for HTTP round trip (fire-and-forget over socket) but reflects optimistic local state, corrected if a subsequent `host_status_update` broadcast disagrees.
- Visually reflect connection state (socket connected/disconnected badge) since availability changes silently fail if the socket is down.

---

### 5.6 Feature: Admin — List Host Applications

**Endpoint:** `GET /admin/host-applications` — role: `admin` / `super_admin`

**Query params:** `status` (optional filter), `page` (default 1), `limit` (default 20, max 100)

**Bloc:** `AdminApplicationsBloc` (paginated list pattern)

**Events:**
```dart
FetchApplications({status, page})
RefreshApplications
LoadMoreApplications
FilterByStatus(ApplicationStatus? status)
```

**States:**
```dart
AdminApplicationsLoading
AdminApplicationsLoaded(items, page, total, hasMore)
AdminApplicationsLoadingMore
AdminApplicationsError(String message)
```

**UI requirements:**
- Filter chips: All / Pending / Approved / Rejected.
- Infinite-scroll or "Load more" list, each row shows avatar, `fullName`, `phone`, truncated `bio`, status chip.
- Tapping a row opens the Application Detail screen (§5.7).
- Entire screen gated to `admin` / `super_admin` only.

---

### 5.7 Feature: Admin — Approve / Reject Application

**Endpoints:**
- `POST /admin/host-applications/:id/approve`
- `POST /admin/host-applications/:id/reject` — body `{ "rejectionReason": string }`

**Bloc:** `ApplicationReviewBloc`

**Events:**
```dart
ApproveApplication(String id)
RejectApplication(String id, String rejectionReason)
```

**States:**
```dart
ReviewActionInProgress
ApplicationApproved(HostApplication updated)
ApplicationRejected(HostApplication updated)
ReviewActionFailure(String message)
```

**UI requirements:**
- Detail screen shows full bio, KYC document images (front/back/selfie) in a zoomable viewer, and Approve / Reject buttons.
- Reject requires a mandatory reason text field (modal) before the action is enabled.
- Note: approval upgrades the target user's role from `client` → `staff` and initializes their host wallet server-side; on success remove the item from the pending list (optimistic) and show a confirmation toast.
- After either action, the corresponding socket event fires to the *target user's* device — this screen (admin's) does not need to listen for it, but see §6 for the affected user's experience.

---

### 5.8 Feature: Admin — Assign Target Milestone

**Endpoint:** `POST /admin/hosts/:hostId/targets` — role: `admin` / `super_admin`. Use `hostId = "all"` to broadcast to all active hosts.

**Validation:**
| Field | Rule |
|---|---|
| `period` | Required, `weekly` \| `monthly` |
| `startDate` | Required, ISO date-time |
| `endDate` | Required, ISO date-time, after `startDate` |
| `targetType` | Required, `call_minutes` \| `points_earned` \| `total_calls` |
| `targetValue` | Required, positive number |

**Bloc:** `AssignMilestoneBloc`

**Events:**
```dart
AssignMilestone({hostId, period, startDate, endDate, targetType, targetValue})
```

**States:**
```dart
MilestoneAssigning
MilestoneAssignSuccess
MilestoneAssignFailure(String message)
```

**UI requirements:**
- Form with: host picker (search by name/phone, or an "All Hosts" switch that sets `hostId = "all"`), period segmented control, date range picker (`endDate` must be after `startDate` — enforce in UI before submit), target type dropdown, numeric target value input (must be > 0).
- Confirmation dialog when broadcasting to "all" hosts, since this is a high-impact action.

---

### 5.9 Feature: Host — My Target Milestones

**Endpoint:** `GET /hosts/my-targets` — role: `staff`

**Bloc:** `HostTargetsCubit`

**States:**
```dart
TargetsLoading
TargetsLoaded(List<HostTarget> targets)
TargetsError(String message)
TargetsEmpty
```

**UI requirements:**
- Card list, each showing: target type label, period, progress bar (`currentValue / targetValue`), status chip (`in_progress` grey, `achieved` green with a celebratory icon/animation).
- Progress must update live: when a call ends (`POST /calls/:callId/end`, driven by the call module, out of scope here) the backend recalculates `currentValue` and flips status to `achieved` automatically once the threshold is met — this screen should support pull-to-refresh and, if available, refresh after returning from a completed call session.

---

## 6. Socket.IO Event Handling

| Direction | Event | Consumed by |
|---|---|---|
| Server → Client | `host_application_approved` | Individual applicant device |
| Server → Client | `host_application_rejected` | Individual applicant device |
| Server → All | `host_status_update` | All connected clients (browsing/calling screens) |
| Client → Server | `update_availability` | Emitted by host device (§5.5) |

### 6.1 `host_application_approved`
```json
{ "message": "Congratulations! Your Host Application has been approved. Please log in again to activate your host dashboard." }
```
**Required frontend flow (must be implemented exactly, per backend contract):**
1. Show a congratulations dialog with the received message.
2. On user tapping OK, trigger full logout: clear all stored access/refresh tokens and Bloc state.
3. Redirect to the OTP login screen so a fresh JWT carrying the `staff` role is issued.

This must be wired as a **global** listener (e.g., in `AppBloc` / root-level listener), not scoped to a single screen, since the event can arrive while the user is anywhere in the app.

### 6.2 `host_application_rejected`
```json
{ "message": "Your Host Application has been rejected. Reason: <reason>" }
```
**Required frontend flow:**
1. Show a notification/snackbar/dialog surfacing the rejection reason (parsed from the message or, preferably, from a structured payload field if backend later adds one).
2. Deep-link/guide the user back to the application edit screen (§5.1) to correct and resubmit.

### 6.3 `host_status_update`
Broadcast to all connected clients whenever any host's availability changes (triggered server-side after processing `update_availability`). Consumed by any screen listing/browsing online hosts (out of scope for this document's screens, but the `SocketService` stream must expose this event for other modules to subscribe to).

---

## 7. Error Handling & Edge Cases

- **401/403 responses:** any protected call returning 401 triggers global logout + redirect to login; 403 (wrong role) should never occur if route guards are correct, but must fail gracefully with a "Not authorized" screen rather than crashing.
- **Validation errors (400):** backend field-level errors must be mapped and shown inline under the corresponding form field, not just as a generic toast.
- **Network/timeout:** all Blocs expose a retry-capable failure state; list screens (§5.6, §5.9) support pull-to-refresh as a retry mechanism.
- **Socket disconnect:** `SocketService` auto-reconnects with backoff; UI shows a non-blocking "reconnecting…" indicator on the Host Dashboard rather than freezing interactions.
- **Stale role after approval without socket delivery (app was killed):** on app resume/login, always re-fetch `GET /host-applications/my-status` and re-derive role from a fresh JWT rather than trusting cached role state, as a fallback to §6.1.

---

## 8. Non-Functional Requirements

| Requirement | Detail |
|---|---|
| State management | `flutter_bloc` exclusively; no `setState`-driven business logic |
| Testability | Every Bloc/Cubit must have unit tests covering success, validation-failure, and server-failure paths using `bloc_test` |
| Navigation | Role-aware routing (`go_router` recommended) with a `RoleGuard` redirect for unauthorized route access |
| Offline resilience | Cached last-known `HostApplication` / `HostPreferences` shown with a "stale data" indicator when offline |
| Accessibility | All form fields labeled; status chips carry both color and text/icon (not color alone) |
| Localization | All user-facing strings (including socket message text) routed through the app's i18n layer, not hardcoded |
| Security | JWT stored via `flutter_secure_storage`; never logged in plaintext |

---

## 9. API Quick Reference (for implementation checklist)

| Method | Endpoint | Role | Feature Section |
|---|---|---|---|
| POST | `/host-applications/apply` | client | §5.1 |
| POST | `/host-applications/kyc` | client | §5.2 |
| GET | `/host-applications/my-status` | client/staff | §5.3 |
| PATCH | `/hosts/preferences` | staff | §5.4 |
| (socket) | `update_availability` | staff | §5.5 |
| GET | `/admin/host-applications` | admin/super_admin | §5.6 |
| POST | `/admin/host-applications/:id/approve` | admin/super_admin | §5.7 |
| POST | `/admin/host-applications/:id/reject` | admin/super_admin | §5.7 |
| POST | `/admin/hosts/:hostId/targets` | admin/super_admin | §5.8 |
| GET | `/hosts/my-targets` | staff | §5.9 |
| (socket) | `host_application_approved` | client → staff | §6.1 |
| (socket) | `host_application_rejected` | client | §6.2 |
| (socket) | `host_status_update` | all | §6.3 |

---

## 10. Acceptance Criteria Summary

- [ ] A `client` can complete apply → KYC → status-check flow end-to-end with inline validation matching backend rules exactly.
- [ ] A `staff` user sees the Host Dashboard with working preferences form and availability toggles, and cannot see any client-onboarding or admin screens.
- [ ] An `admin`/`super_admin` can list, filter, paginate, approve, reject, and assign milestones, and cannot see host-only dashboard screens.
- [ ] Receiving `host_application_approved` anywhere in the app forces logout and redirect to login, exactly per §6.1.
- [ ] Receiving `host_application_rejected` surfaces the reason and offers resubmission.
- [ ] All Bloc states are unit-tested; all screens are route-guarded by role.
- [ ] No hardcoded role checks scattered across widgets — a single `RoleGuard`/`AuthBloc.role` source of truth is used throughout.