//
//  Dependencies.swift
//  AIChat
//  swiftlint:disable function_body_length
//  Created by Youssef Mohamed on 29/06/2026.
//
import Foundation
import Firebase
import SwiftUI

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, production

    func configure() {
        switch self {
        case .mock:
            break // Doesn't need a configuration

        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
            
        case .production:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}

@MainActor
struct Dependencies {
    let container: DependencyContainer

    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager

    init(buildConfig: BuildConfiguration) {
        switch buildConfig {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [ConsoleService(printParams: false)])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager)
            userManager = UserManager(services: MockUserServicesContainer(user: isSignedIn ? .mock : nil), logManager: logManager)
            aiManager = AIManager(aiServices: MockAIServices())
            avatarManager = AvatarManager(services: MockAvatarServices())
            chatManager = ChatManager(service: MockChatService())
            abTestManager = ABTestManager(
                service: MockABTestService(
                    createAccountTest: true,
                    onboardingCommunityTest: true,
                    categoryRowTest: .default
                ),
                logManager: logManager
            )

        case .dev:
            logManager = LogManager(
                services: [
                    ConsoleService(printParams: true),
                    FirebaseAnalyticsService(),
                    MixpanelService(token: Secrets.mixpanelToken, loggingEnabled: true),
                    FirebaseCrashlyticsService()
                ]
            )
            authManager = AuthManager(service: FirebaseAuthServices(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServicesContainer(), logManager: logManager)
            aiManager = AIManager(aiServices: ProductionAIServices())
            avatarManager = AvatarManager(services: ProductionAvatarServices())
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(service: LocalABTestService(), logManager: logManager)

        case .production:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                MixpanelService(token: Secrets.mixpanelToken, loggingEnabled: false),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthServices(), logManager: logManager)
            userManager = UserManager(services: ProductionUserServicesContainer(), logManager: logManager)
            aiManager = AIManager(aiServices: ProductionAIServices())
            avatarManager = AvatarManager(services: ProductionAvatarServices())
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(service: FirebaseABTestService(logManager: logManager), logManager: logManager)
        }

        pushManager = PushManager() /// same manager for all builds

        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(ChatManager.self, service: chatManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(ABTestManager.self, service: abTestManager)

        self.container = container
    }
}

@MainActor
@Observable
class DependencyContainer {
    private var services: [String: Any] = [:]

    /// puts the Manager name as a key string with its type and class passed as the value
    func register<T>(_ type: T.Type, service: T) {
        let key = "\(type)"
        services[key] = service
    }

    /// puts the Manager name as a key string with its type and class passed as the value
    func register<T>(_ type: T.Type, service: () -> T) {
        let key = "\(type)"
        services[key] = service()
    }

    /// gets the value of this key (which is string name of this class) from the map
    func resolve<T>(_ type: T.Type) -> T? {
        let key = "\(type)"
        return services[key] as? T
    }
}


@MainActor
final class DevPreview {
    static let shared = DevPreview()

    /// Returns a fresh container on every access, so previews can register
    /// overrides (e.g. a slow AvatarManager) without affecting other previews.
    var container: DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(ChatManager.self, service: chatManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(ABTestManager.self, service: abTestManager)
        return container
    }

    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager

    init() {
        self.logManager = LogManager(services: [ConsoleService(printParams: false)])
        self.authManager = AuthManager(service: MockAuthService(user: .mock()), logManager: logManager)
        self.userManager = UserManager(services: MockUserServicesContainer(user: .mock), logManager: logManager)
        self.aiManager = AIManager(aiServices: MockAIServices())
        self.avatarManager = AvatarManager(services: MockAvatarServices())
        self.chatManager = ChatManager(service: MockChatService())
        self.pushManager = PushManager()
        self.abTestManager = ABTestManager(service: MockABTestService(createAccountTest: true, onboardingCommunityTest: true, categoryRowTest: .default), logManager: logManager)
    }
}
