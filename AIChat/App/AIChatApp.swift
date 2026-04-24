//
//  AIChatApp.swift
//  AIChat
//
//  Created by Youssef Mohamed on 02/03/2026.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    lazy var dependencies = Dependencies()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        _ = dependencies
        return true
    }
}

@main
struct AIChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.chatManager)
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

    init() {
        authManager = AuthManager(service: FirebaseAuthServices())
        userManager = UserManager(services: ProductionUserServicesContainer())
        aiManager = AIManager(aiServices: ProductionAIServices())
        avatarManager = AvatarManager(services: ProductionAvatarServices())
        chatManager = ChatManager(service: FirebaseChatService())
    }
}

extension View {
    func previewEnvironment(
        isSignedIn: Bool = true,
        remoteAvatarService: RemoteAvatarService = MockAvatarService(),
        localAvatarPersistence: LocalAvatarPersistence = MockLocalAvatarPersistence()
    ) -> some View {
        self
            .environment(UserManager(services: MockUserServicesContainer(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AvatarManager(services: MockAvatarServices(remote: remoteAvatarService, local: localAvatarPersistence)))
            .environment(AIManager(aiServices: MockAIServices()))
            .environment(ChatManager(service: MockChatService()))
            .environment(AppState())
    }
}
