//
//  AIChatApp.swift
//  AIChat
//
//  Created by Youssef Mohamed on 02/03/2026.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        #if !MOCK
        FirebaseApp.configure()
        #endif

        #if MOCK
        dependencies = Dependencies(buildConfig: .mock(isSignedIn: true))
        #elseif DEV
        dependencies = Dependencies(buildConfig: .dev)
        #else
        dependencies = Dependencies(buildConfig: .production)
        #endif
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
