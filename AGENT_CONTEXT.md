# AGENT_CONTEXT

## Purpose
This file is the persistent handoff context for future AI coding sessions working in this repository.

Read this file before making any changes.

## Project Overview
`AIChat` is a SwiftUI iOS app for:
- browsing AI avatars
- creating custom avatars with AI-generated images
- chatting with avatars using AI-generated text responses
- managing user identity, onboarding, profile data, and chat history

The app uses Firebase for authentication, remote data, and image storage. It also uses local persistence for selected user data and recent avatars.

## Architecture Summary
The project uses a lightweight layered SwiftUI architecture built around:
- `@Observable` manager classes for app/domain state
- SwiftUI `@Environment(...)` injection for shared dependencies
- protocol-based service abstractions
- separate production and mock service implementations
- local and remote persistence split by domain
- view-local UI state with async calls into managers

This is not a classic MVVM setup with a view model per screen.

Instead:
- views own their temporary UI state with `@State`
- shared domain state lives in managers such as `AuthManager`, `UserManager`, `AIManager`, `AvatarManager`, and `ChatManager`
- managers delegate work to services
- services hide concrete infrastructure details like Firebase, SwiftData, FileManager, and external AI APIs

## Core Architectural Patterns

### 1. App-Level Dependency Injection
The app entry point is `AIChat/App/AIChatApp.swift`.

At launch:
- Firebase is configured in `AppDelegate`
- a `Dependencies` container builds concrete manager instances once
- those managers are injected into the SwiftUI environment

This means most feature views consume shared state like this:
- `@Environment(AuthManager.self)`
- `@Environment(UserManager.self)`
- `@Environment(ChatManager.self)`

Do not replace this with a different dependency injection style unless explicitly requested.

### 2. Global App State
`AIChat/Core/AppView/AppState.swift` holds high-level UI routing state, currently centered around `showTabBar`.

Responsibilities:
- gate the app between onboarding/welcome and the main tab-based app shell
- persist that gate in `UserDefaults`

`AppView` checks authentication/user status on launch and decides whether to show:
- `WelcomeView` / onboarding flow
- `TabBarView`

### 3. Manager + Service Layering
Each domain uses a manager that exposes a clean interface to views.

Examples:
- `AuthManager` wraps `AuthService`
- `UserManager` wraps `RemoteUserService` + `LocalUserPersistence`
- `AvatarManager` wraps `RemoteAvatarService` + `LocalAvatarPersistence`
- `AIManager` wraps `AITextService` + `AIImageService`
- `ChatManager` wraps `ChatService`

Views should talk to managers, not directly to Firebase or raw service implementations.

### 4. Production vs Mock Implementations
The app is intentionally structured for previews and safe UI iteration.

Patterns already in use:
- service protocols
- production containers
- mock containers
- preview environment helpers

Examples:
- `ProductionUserServicesContainer` vs `MockUserServicesContainer`
- `ProductionAIServices` vs `MockAIServices`
- `ProductionAvatarServices` vs `MockAvatarServices`
- `previewEnvironment(...)` in `AIChatApp.swift`

If future work adds a new service boundary, keep this pattern.

### 5. Async Data Flow
The app uses:
- `async/await`
- `Task`
- `AsyncStream`
- `AsyncThrowingStream`

Realtime flows include:
- auth state changes
- user document streaming
- chat message streaming

Views often trigger async work in:
- `.task`
- `.onAppear`
- button actions

## Folder Structure

### Top Level
- `AIChat/`
- `AIChat.xcodeproj/`
- `AIChatTests/`
- `AIChatUITests/`

### Inside `AIChat/`
- `App/`
  - app entry point and dependency wiring
- `Core/`
  - feature screens and navigation flows
- `Components/`
  - reusable UI building blocks
- `Services/`
  - managers, models, service protocols, and implementations
- `Extensions/`
  - reusable extensions for SwiftUI/Foundation helpers
- `Utilities/`
  - constants, secrets access, shared utility aliases
- `ViewModifiers/`
  - reusable modifiers and button styles
- `Assets.xcassets/`
  - app assets

### `Core/` Feature Areas
- `AppView/`
- `CategoryList/`
- `Chat/`
- `CreateAccount/`
- `CreateAvatar/`
- `Explore/`
- `Onboarding/`
- `Profile/`
- `Root/`
- `Routing/`
- `Settings/`
- `TabBar/`
- `UserChats/`
- `Welcome/`

This app is organized primarily by feature at the screen level, with shared domain logic extracted into `Services/`.

### `Components/`
Reusable UI is split by purpose:
- `Alerts/`
- `Buttons/`
- `Fields/`
- `Images/`
- `Loaders/`
- `Modals/`
- `Views/`

Notable pattern:
- some reusable components have a paired builder/wrapper view such as `ChatRowCellViewBuilder` and `ChatBubbleViewBuilder`
- builders are used when a reusable view needs feature-specific async loading or adaptation

### `Services/`
This is the main domain/infrastructure layer.

Current domains:
- `AI/`
- `Auth/`
- `Avatar/`
- `Chat/`
- `ImageUpload/`
- `User/`

Typical internal structure per domain:
- `Manager`
- `Models`
- `Services`
  - protocol(s)
  - `Remote/`
  - `Local/`
  - mock implementation(s)
  - production implementation(s)

## Data Flow

### App Launch and User Bootstrap
1. `AIChatApp` creates concrete managers and injects them through the environment.
2. `AppView` runs `checkUserStatus()`.
3. If Firebase already has an authenticated user:
   - `AuthManager` exposes it
   - `UserManager.logIn(...)` ensures user data is available and starts a user stream
4. If no authenticated user exists:
   - the app signs in anonymously
   - `UserManager.logIn(...)` creates/saves the corresponding app user record
5. `AppState.showTabBar` determines whether the app shows onboarding or the tab shell.

### Onboarding Flow
Primary screens:
- `WelcomeView`
- `OnboardingIntroView`
- `OnboardingColorView`
- `OnboardingCompletedView`

Flow:
1. User starts from welcome.
2. User goes through onboarding screens.
3. Final onboarding step calls `userManager.markOnboardingAsCompleted(profileColorHex:)`.
4. `AppState` switches to the main tab bar.

Important note:
- onboarding completion status lives in the remote user record
- app shell visibility is also mirrored locally through `AppState` + `UserDefaults`

### Explore to Chat Flow
Primary screens:
- `ExploreView`
- `CategoryListView`
- `ChatView`

Flow:
1. `ExploreView` loads featured and popular avatars from `AvatarManager`.
2. Selecting an avatar navigates directly to `ChatView`.
3. Selecting a category navigates to `CategoryListView`.
4. Selecting an avatar in the category list pushes `ChatView`.

Navigation is handled with local `NavigationStack` state, not a centralized router object.

### Chat Flow
Primary files:
- `Core/Chat/ChatView.swift`
- `Services/Chat/ChatManager.swift`
- `Services/Chat/Services/FirebaseChatService.swift`
- `Services/AI/AIManager.swift`

Flow:
1. `ChatView` loads avatar details.
2. `ChatView` loads an existing chat for `(userId, avatarId)` or creates one on first send.
3. `ChatView` listens to realtime message updates through `chatManager.streamChatChanges(...)`.
4. When the user sends a message:
   - it is stored through `ChatManager`
   - the UI scrolls immediately
   - the app asks `AIManager` to generate a text response using avatar context and recent conversation
5. The generated avatar response is added as a chat message.
6. Seen status is updated through `userHasSeenMessage(...)`.

Important behavior:
- chat messages stream in realtime from Firebase
- the AI response is orchestrated in `ChatView`, not inside the service layer

### Create Avatar Flow
Primary screen:
- `Core/CreateAvatar/CreateAvatarView.swift`

Flow:
1. User enters a name and character attributes.
2. `AIManager.generateImage(...)` generates a preview image.
3. On save:
   - an `Avatar` model is created
   - `AvatarManager.createAvatar(...)` is called
   - `FirebaseAvatarService` uploads the image to Firebase Storage
   - the avatar document is saved in Firestore with the stored image URL

### Profile and Settings Flow
Primary screens:
- `ProfileView`
- `SettingsView`

Profile responsibilities:
- show current user profile color
- show current user avatars
- launch avatar creation
- delete avatars

Settings responsibilities:
- create account from anonymous usage
- sign out
- delete account
- show app metadata

Delete account flow coordinates multiple domains in parallel:
- remove avatar author ownership
- delete user document
- delete auth account
- delete all chats for the user

## Local vs Remote Persistence

### Remote
Firebase is the main remote backend:
- Firebase Auth for authentication
- Firestore for users, avatars, chats, and chat messages
- Firebase Storage for avatar images

### Local
Current local persistence is intentionally small and targeted:
- `FileManagerUserPersistence` stores the current user snapshot locally
- `SwiftDataLocalAvatarPersistence` stores recent avatars
- `UserDefaults` stores the tab/onboarding gate flag

Do not collapse these into one persistence mechanism unless explicitly requested.

## Component Communication
Components communicate mainly through:
- SwiftUI environment managers
- local `@State` and `@Binding`
- closure callbacks
- async streams for live updates

Examples:
- `ChatsView` passes async loader closures into `ChatRowCellViewBuilder`
- `WelcomeView` passes an `onDidSignIn` callback into `LinkProviderView`
- `CategoryListView` receives a bound navigation path from `ExploreView`
- `ChatView` toggles a modal using local state and reusable modal support helpers

This means communication is intentionally simple and feature-local rather than heavily abstracted.

## Coding Style Rules
Follow the existing style before introducing new patterns.

### Structural Rules
- Keep feature screens in `Core/`.
- Keep shared reusable UI in `Components/`.
- Keep domain logic in managers/services under `Services/`.
- Keep persistence concerns split into `Remote` and `Local` where applicable.
- Prefer additive changes inside the existing structure over architectural refactors.

### View Rules
- Use SwiftUI views with small helper computed properties for subviews.
- Keep business logic in `extension ViewName { ... }` blocks when that matches the existing file style.
- Use `@State` for view-local transient state.
- Use environment managers for shared domain state.
- Do not introduce a screen-specific view model layer unless explicitly requested.

### Service Rules
- Depend on protocols at the manager boundary.
- Keep production and mock implementations available.
- If a domain already has a services container pattern, continue using it.
- Keep infrastructure details out of views.

### Preview Rules
- Preserve preview support.
- Prefer using mocks in previews.
- Reuse `previewEnvironment(...)` when possible.

### Async Rules
- Use `async/await` consistently.
- Preserve realtime stream-based behavior where it already exists.
- Be careful with UI updates that depend on async tasks and environment state.

### Existing Lint Context
Current `.swiftlint.yml` is permissive in a few areas:
- `line_length.warning = 500`
- `type_body_length.warning = 500`
- `file_length.warning = 750`
- some whitespace and identifier rules are disabled

This does not mean style should become loose. Keep code readable and aligned with nearby files.

## Things The Agent Must Not Change Without Explicit User Approval
- Do not refactor the overall architecture.
- Do not replace environment-based manager injection with another DI system.
- Do not introduce a broad MVVM rewrite.
- Do not merge managers directly into views or bypass managers by calling Firebase from feature screens.
- Do not remove mock services, mock containers, or preview helpers.
- Do not reorganize the folder structure unless the user explicitly asks for it.
- Do not change the onboarding/tab-bar gate behavior unless the task is specifically about that flow.
- Do not replace local persistence choices casually.
- Do not change chat identity rules such as chat pairing by `userId + avatarId` unless explicitly required.
- Do not remove realtime chat streaming behavior.

## Current Priorities
These are inferred from the current codebase structure and should be treated as the working default until the user says otherwise.

- Preserve the current architecture instead of redesigning it.
- Keep new work aligned with existing domain boundaries.
- Prefer focused feature work over repo-wide cleanup.
- Maintain previewability and mock-backed development flows.
- Protect realtime chat behavior and Firebase-backed data flows.
- Keep onboarding, profile, avatar, and chat flows stable while iterating.

## How To Continue Work Safely
When starting a new task in this repo:

1. Read this file first.
2. Identify the affected feature folder in `AIChat/Core/`.
3. Identify the related manager in `AIChat/Services/`.
4. Trace whether the change also touches:
   - a remote service
   - a local persistence layer
   - a shared component
   - previews/mocks
5. Make the smallest change that fits the existing structure.
6. Avoid unrelated cleanup.
7. Verify that previews, navigation assumptions, and async flows still make sense.

### Safe Change Heuristics
- If the UI needs data, first ask whether that data should come from an existing manager.
- If a view is getting too much infrastructure knowledge, move that knowledge down into a manager or service.
- If a new dependency is needed, prefer a protocol-backed service and preserve mockability.
- If a reusable component needs async data unique to a feature, consider the existing builder-wrapper pattern.
- If a change affects auth, user, chat, or avatar identity, trace the full flow before editing.

## Important Files To Read First
For most sessions, start here:
- `AIChat/App/AIChatApp.swift`
- `AIChat/Core/AppView/AppView.swift`
- `AIChat/Core/AppView/AppState.swift`
- `AIChat/Services/Auth/Managers/AuthManager.swift`
- `AIChat/Services/User/UserManager.swift`
- `AIChat/Services/Avatar/AvatarManager.swift`
- `AIChat/Services/AI/AIManager.swift`
- `AIChat/Services/Chat/ChatManager.swift`

Then read the specific feature files involved in the task.

## Final Guidance For Future Agents
This codebase is already structured around clear domain boundaries.

Work with the grain of the project:
- preserve the manager/service split
- respect feature-based screen organization
- keep views lightweight
- keep infrastructure behind service abstractions
- extend mock and preview support when adding behavior

If a requested change seems to require a broad architectural rewrite, stop and get explicit user confirmation before proceeding.
