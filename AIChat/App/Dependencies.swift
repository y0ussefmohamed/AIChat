//
//  Dependencies.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/06/2026.
//
import Foundation
import SwiftUI

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
