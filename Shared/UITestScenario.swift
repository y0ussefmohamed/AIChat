/// Scenario names are shared so launch configuration cannot drift from fixture wiring.
nonisolated enum UITestScenario: String, CaseIterable, Sendable {
    case standard, anonymous, accountPrompt
    case emptyProfile, emptyChats, emptyConversation, emptyCategory
    case communityDisabled, categoriesTop, categoriesHidden
    case authFailure, profileFailure, categoryFailure, avatarSaveFailure
    case imageFailure, sendFailure, reportFailure, deleteChatFailure, messageStreamFailure
    case onboardingFailure, signOutFailure, deleteAccountFailure, replyFailure
    case slowOnboarding, slowAvatarSave, slowReply, notificationsDenied
}

nonisolated enum UITestFixture {
    static let userId = "ui-user"
    static let alphaId = "alpha"
    static let betaId = "beta"
    static let alphaChatId = "ui-user_alpha"
    static let betaChatId = "ui-user_beta"
    static let greetingId = "alpha-greeting"
    static let previousUserMessageId = "alpha-user-message"
    static let greeting = "Hello from Alpha."
    static let previousUserMessage = "Tell me about yourself."
    static let betaGreeting = "Hello from Beta."
    static let reply = "Hello! This is the UI test reply."
    static let failure = "The UI test requested this failure."
}
