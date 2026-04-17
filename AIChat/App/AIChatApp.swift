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
        }
    }
}

struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager

    init() {
        self.authManager = AuthManager(service: FirebaseAuthServices())
        self.userManager = UserManager(services: ProductionUserServicesContainer())
        self.aiManager = AIManager(service: PollinationsAIService())
        self.avatarManager = AvatarManager(services: ProductionAvatarServices())
    }
}
