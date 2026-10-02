# UI Testing Rebuild Implementation Plan

**Goal:** Replace the existing UI tests with tests that use stable control identifiers and deterministic scenarios while mirroring the app's folder structure.

**Architecture:** Compile a shared identifier/scenario contract into the app and UI-test target. Enable in-memory scenario services only in Mock builds launched with `--ui-testing`; preserve ordinary Mock, Development, and Production wiring. Exercise existing screen navigation instead of introducing test-only views.

**Execution:** Implement inline, without subagents. The user authorized view edits and UI tests. Build for testing to verify compilation; do not execute tests. Preserve previous unit tests and unrelated workspace changes.

## Global Constraints

- Keep `AIChat_UITests/Core` and `Components` aligned with the corresponding source paths.
- Preserve view appearance and business rules; add accessibility metadata and semantic controls where needed.
- Keep both test targets parallelizable in `AIChat - Mock`.
- Use isolated, in-memory data for each app launch and offline avatar images.
- Do not modify analytics tracking or add dependencies.

## Tasks

- [x] Add the shared identifier/scenario files to both targets and wire opt-in Mock fixtures at app launch.
- [x] Add fixed avatar/user/chat data, persistent avatar creation, continuing message streams, and selected failure/delay scenarios.
- [x] Add identifiers and accessibility labels to screens, controls, rows, fields, and shared components.
- [x] Replace every existing UI test and helper with fresh scenario-driven tests. Verify happy paths, empty states, error handling, loading, persistence, navigation, and shared component behavior.
- [x] Update the UI-test README with setup, scenario isolation, parallel execution, coverage, and runtime limits.
- [x] Check folder correspondence, identifier coverage, lint, project syntax, and a simulator build for testing; report build results separately from unexecuted tests.
