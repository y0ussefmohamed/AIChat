# Analytics Tracking — Mixpanel

This project uses **Mixpanel** for all product analytics. Mixpanel is the single source of truth for event tracking, user identification, and behavioral data. Do not introduce any other analytics tools, SDKs, or tracking libraries without explicit instruction from a user.

---

## Before You Add or Modify Any Tracking

⛔ **Do not write Mixpanel tracking code without reading this file first.**

Wrong assumptions about platform, identity, or data residency will produce broken Mixpanel data that requires manual cleanup or data deletion requests.

### Mandatory checklist before writing any Mixpanel code

- [x] Confirm you are using the correct Mixpanel SDK for this project's platform (see Tech Stack below)
- [x] Check if this project routes data through a CDP — (No CDP, direct SDK)
- [x] Verify data residency endpoint — **EU Region (`https://api-eu.mixpanel.com`)**
- [ ] Review the existing Mixpanel tracking plan below before adding new events

---

## Tech Stack

| Detail | Value |
|---|---|
| **Platform** | iOS (Swift & SwiftUI) |
| **Mixpanel SDK** | `mixpanel-swift` (via SPM: `https://github.com/mixpanel/mixpanel-swift`) |
| **Server URL** | `https://api-eu.mixpanel.com` (EU Data Residency) |
| **Tracking method** | Client-side iOS |
| **CDP (if any)** | None |
| **Consent required** | No |
| **Mixpanel project token location** | `AIChat/Secrets.plist` (`MIXPANEL_TOKEN`) via `Secrets.mixpanelToken` |

---

## Mixpanel Initialization

Mixpanel is initialized in:

**File:** `AIChat/Services/Logs/Services/MixpanelService.swift`
**Wiring:** `AIChat/App/Dependencies.swift`

```swift
// Initialized in MixpanelService init:
Mixpanel.initialize(
    token: token,
    trackAutomaticEvents: true,
    serverURL: "https://api-eu.mixpanel.com"
)
```

**Do not:**
- Initialize Mixpanel in multiple places
- Create separate Mixpanel instances per component or view
- Call `Mixpanel.mainInstance()` directly in UI views — always dispatch events through `LogManager` via `@Environment(LogManager.self)`

---

## Mixpanel Identity

Mixpanel identity is managed through:

| Action | When to call | Code location |
|---|---|---|
| `mixpanel.identify(user_id)` | On login, signup, or session restore | `AIChat/Services/Auth/Managers/AuthManager.swift` |
| `mixpanel.reset()` | On logout or account deletion | `AIChat/Services/User/UserManager.swift` (`signOut()`) and `MixpanelService.swift` (`deleteUserProfile()`, `resetUser()`) |

**Rules:**
- Call `mixpanel.identify()` with the stable Firebase `uid` — never use email addresses as the Mixpanel distinct_id.
- Call `mixpanel.reset()` on every logout and account deletion path — this clears the distinct_id and generates a new anonymous ID to prevent session bleeding between different user accounts.
- Never call `mixpanel.identify()` with a different user ID without calling `mixpanel.reset()` first.

---

## Mixpanel Tracking Plan

All tracking is dispatched via `LogManager.trackEvent(event:)` conforming to `LoggableEvent`.

### Naming conventions

- Event names: `snake_case` or structured `Domain_Action_Status`
- Property names: `snake_case` (e.g., `sign_up_method`, `avatar_id`, `chat_id`)
- Boolean properties: use `is_` prefix (e.g., `is_new_user`)

### Key Events

| Event | Trigger | Key Properties | File |
|---|---|---|---|
| `sign_up_completed` / `LinkProviderView_CreateAccountEmail_Success` | User links or signs up with email/Apple | `sign_up_method`, `is_new_user` | `AIChat/Core/CreateAccount/LinkProviderView.swift` |
| `message_sent` / `ChatView_SentChatMessage_Start` (Value Moment) | User sends a message to an AI avatar | `chat_id`, `avatar_id`, `user_id` | `AIChat/Core/Chat/ChatView.swift` |
| `avatar_created` / `CreateAvatarView_SaveAvatar_Success` | User creates and saves an AI avatar | `avatar_id`, `character_description` | `AIChat/Core/CreateAvatar/CreateAvatarView.swift` |

---

## How to Add a New Event

1. Check existing events in feature enums conforming to `LoggableEvent` (e.g. `ChatViewEvent`, `CreateAvatarViewEvent`, etc.).
2. Consume `LogManager` via SwiftUI Environment: `@Environment(LogManager.self) private var logManager`.
3. Call `logManager.trackEvent(event: YourEvent)`.
4. Mixpanel will automatically queue and flush the event immediately to `https://api-eu.mixpanel.com`.
