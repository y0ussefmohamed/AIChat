#if MOCK
import Foundation
import UIKit

struct UITestConfiguration {
    let scenario: UITestScenario

    var imageURL: URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("AIChatUITestAvatar.png")
    }

    static var current: Self? {
        guard ProcessInfo.processInfo.arguments.contains("--ui-testing") else { return nil }
        let name = ProcessInfo.processInfo.environment["AICHAT_UI_TEST_SCENARIO"] ?? UITestScenario.standard.rawValue
        guard let scenario = UITestScenario(rawValue: name) else {
            preconditionFailure("Unknown UI test scenario: \(name)")
        }
        return Self(scenario: scenario)
    }

    var auth: UserAuthInfo {
        UserAuthInfo(
            uid: UITestFixture.userId,
            email: "uitests@example.com",
            isAnonymous: scenario == .anonymous || scenario == .accountPrompt,
            creationDate: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }

    var user: UserModel {
        UserModel(userId: auth.uid, email: auth.email, isAnonymous: auth.isAnonymous, profileColorHex: "#3377FF")
    }

    func avatars() -> [Avatar] {
        let imageURL = self.imageURL
        let image = UIGraphicsImageRenderer(size: CGSize(width: 80, height: 80)).image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 80, height: 80))
            UIImage(systemName: "person.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
                .draw(in: CGRect(x: 20, y: 15, width: 40, height: 50))
        }
        do {
            guard let data = image.pngData() else { preconditionFailure("Unable to create UI test avatar image.") }
            try data.write(to: imageURL)
        } catch {
            preconditionFailure("Unable to save UI test avatar image: \(error)")
        }
        let authorId = scenario == .emptyProfile ? "another-user" : UITestFixture.userId
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        return [
            Avatar(avatarId: "alpha", name: "Alpha", characterOption: .alien, characterAction: .smiling, characterLocation: .park, profileImageName: imageURL.absoluteString, authorId: authorId, dateCreated: date),
            Avatar(avatarId: "beta", name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .forest, profileImageName: imageURL.absoluteString, authorId: authorId, dateCreated: date),
            Avatar(avatarId: "gamma", name: "Gamma", characterOption: .cat, characterAction: .drinking, characterLocation: .park, profileImageName: imageURL.absoluteString, authorId: authorId, dateCreated: date),
            Avatar(avatarId: "delta", name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .park, profileImageName: imageURL.absoluteString, authorId: authorId, dateCreated: date)
        ]
    }
}

enum UITestFailure: LocalizedError {
    case requested
    var errorDescription: String? { UITestFixture.failure }
}

extension Dependencies {
    init(uiTestConfiguration config: UITestConfiguration) {
        let log = LogManager(services: [])
        let signedIn = config.auth
        let member = UserAuthInfo(uid: signedIn.uid, email: signedIn.email, isAnonymous: false)
        let anonymous = UserAuthInfo(uid: signedIn.uid, isAnonymous: true)
        let authService = MockAuthService(user: signedIn)
        authService.signInAnonymouslyResult = .success((anonymous, true))
        authService.signInEmailResult = config.scenario == .authFailure ? .failure(UITestFailure.requested) : .success((member, false))
        authService.createAccountEmailResult = config.scenario == .authFailure ? .failure(UITestFailure.requested) : .success((member, true))
        if config.scenario == .signOutFailure { authService.signOutError = UITestFailure.requested }
        if config.scenario == .deleteAccountFailure { authService.deleteAccountErrors = [UITestFailure.requested] }

        let avatars = config.avatars()
        logManager = log
        authManager = AuthManager(service: authService, logManager: log)
        userManager = UserManager(services: UITestUserServices(config: config), logManager: log)
        aiManager = AIManager(aiServices: UITestAIServices(scenario: config.scenario))
        avatarManager = AvatarManager(services: MockAvatarServices(
            remote: UITestAvatarService(avatars: avatars, scenario: config.scenario),
            local: UITestAvatarPersistence(avatars: avatars)
        ))
        chatManager = ChatManager(service: UITestChatService(scenario: config.scenario))
        pushManager = PushManager(service: UITestPushService(scenario: config.scenario))
        abTestManager = ABTestManager(service: MockABTestService(
            createAccountTest: config.scenario == .accountPrompt,
            onboardingCommunityTest: config.scenario != .communityDisabled,
            categoryRowTest: config.scenario == .categoriesHidden ? .hidden : (config.scenario == .categoriesTop ? .top : .original)
        ), logManager: log)
    }
}
#endif
