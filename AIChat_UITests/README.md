# UI tests

The UI suite was rebuilt around the real app screens, shared accessibility identifiers, and deterministic Mock scenarios. `Core` and `Components` mirror the corresponding folders under `AIChat`; navigation and launch helpers live under `Support`.

## Running

Select **AIChat - Mock**, select an **iPhone simulator**, and press **Command-U** to run unit and UI tests together. To run only UI tests, use the test navigator's run button next to `AIChatUITests`.

Both test targets allow parallel execution. Xcode can distribute suites across simulator clones and chooses the worker count automatically. Each UI test launches a fresh app process with its own in-memory fixture state; nothing is shared between workers.

Tests are authored for an iPhone in portrait orientation. English language/locale arguments stabilize the labels exposed by native alerts, menus, keyboards, navigation, and tabs.

## Test setup

- `Shared/AccessibilityID.swift` is compiled into the app and UI-test runner. Controls, fields, rows, modals, and messages use the same identifier definitions in both targets.
- `Shared/UITestScenario.swift` defines scenario names and fixed fixture content. Helpers launch with `--ui-testing` and the `AICHAT_UI_TEST_SCENARIO` environment variable.
- Fixture services live under `AIChat/App/UITesting` and are compiled only with `MOCK`. App launch selects them only when `--ui-testing` is present. Ordinary Mock launches and Development/Production wiring retain their original services.
- Fixture users, avatars, chats, dates, and ordering are fixed. Avatar creation/deletion persists in memory for that process; messages and read state publish through continuing streams.
- The host supplies a local image source through the image-loader environment, including on Welcome and loading placeholders. UI-test launches use no remote avatar-image downloads, real account service, AI service, analytics SDK, or OS notification authorization request.
- No coordinate taps or SF Symbol guesses are used. Native alert/menu/keyboard/navigation/tab actions use their platform labels; app controls use identifiers. Gestures operate on identified lists, carousels, and rows.
- Failures retain a screenshot and accessibility hierarchy attachment for debugging.

## Coverage

The 94 tests in 33 suites cover:

- Welcome, initial root selection, main tabs, retained tab navigation, both onboarding experiment routes, accessible color selection, successful setup and setup failure.
- Sign-in, account creation, mode switching, field preservation, password visibility, anonymous backup entry, and authentication failure.
- Featured/popular/category navigation, category placement/visibility experiments, anonymous account prompts, deterministic notification prompt acceptance/decline/denial, and developer overrides.
- Owned and empty avatar lists, category filtering/empty states/failures, avatar deletion, form reset, attribute selection, image generation failure, validation, saving, save failure, and loading/disabled action states.
- Resolved chat rows, recent avatars, empty chats, seeded user/avatar bubbles, timestamps, live message and reply updates, new conversations, long bubbles, typing, read-state updates, report/delete/cancel actions, send/report/delete/reply error alerts, and the existing empty-conversation fallback after a message-stream failure.
- Settings information, sign-out/deletion success and failure, destructive confirmation/cancellation, custom/profile modals, modal lifecycle, shared fields/buttons/cells, carousel paging, and accessible avatar images.

## Limits

This suite exercises UI behavior against in-memory fixtures. It does not establish Firebase/API/network integration, OS notification scheduling, Apple sign-in, StoreKit ratings, external policy/mail handling, or persistence across app process termination. Decorative shimmer/gradient effects are exercised by host screens rather than pixel comparisons.

Explore currently assigns loading errors to an alert state without presenting that state, and its retry button is not placed in the view. The rebuild preserves that behavior rather than inventing an error flow for the tests.

Chat currently logs message-stream failures without presenting an error alert. Its test verifies that the empty conversation and composer remain available, without claiming that a failed stream resumes.

## Verification status

The first full run supplied by the user on iPhone 17e (iOS 27) reported nine UI failures. Its saved screenshots, accessibility hierarchies, and activity logs were used to correct empty-field assertions, native popover dismissal, toggle targeting, sheet-dismissal targeting, and illustration accessibility. The account-deletion confirmation now has separate state from error alerts, and the deletion-failure fixture also fails authentication deletion to prevent a successful parallel branch from signing out.

Corrections are validated with builds and static checks only. A new Command-U run is needed to establish runtime results after these changes.
