//
//  Dependencies.swift
//  AIChat
//
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
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager

    init(buildConfig: BuildConfiguration) {
        switch buildConfig {
        case .mock(isSignedIn: let isSignedIn):
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
            userManager = UserManager(services: MockUserServicesContainer(user: isSignedIn ? .mock : nil))
            aiManager = AIManager(aiServices: MockAIServices())
            avatarManager = AvatarManager(services: MockAvatarServices())
            chatManager = ChatManager(service: MockChatService())
            logManager = LogManager(services: [ConsoleService(printParams: false)])
        case .dev:
            authManager = AuthManager(service: FirebaseAuthServices())
            userManager = UserManager(services: ProductionUserServicesContainer())
            aiManager = AIManager(aiServices: ProductionAIServices())
            avatarManager = AvatarManager(services: ProductionAvatarServices())
            chatManager = ChatManager(service: FirebaseChatService())
            logManager = LogManager(services: [
                ConsoleService(printParams: true), FirebaseAnalyticsService()
            ])
        case .production:
            authManager = AuthManager(service: FirebaseAuthServices())
            userManager = UserManager(services: ProductionUserServicesContainer())
            aiManager = AIManager(aiServices: ProductionAIServices())
            avatarManager = AvatarManager(services: ProductionAvatarServices())
            chatManager = ChatManager(service: FirebaseChatService())
            logManager = LogManager(services: [
                FirebaseAnalyticsService()
            ])
        }
    }
}

extension View {
    func previewEnvironment(
        isSignedIn: Bool = true,
        remoteAvatarService: RemoteAvatarService = MockAvatarService(),
        localAvatarPersistence: LocalAvatarPersistence = MockLocalAvatarPersistence()
    ) -> some View {
        self
            .environment(AppState())
            .environment(UserManager(services: MockUserServicesContainer(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AvatarManager(services: MockAvatarServices(remote: remoteAvatarService, local: localAvatarPersistence)))
            .environment(AIManager(aiServices: MockAIServices()))
            .environment(ChatManager(service: MockChatService()))
            .environment(LogManager(services: []))
    }
}
