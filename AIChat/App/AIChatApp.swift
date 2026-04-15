//
//  AIChatApp.swift
//  AIChat
//
//  Created by Youssef Mohamed on 02/03/2026.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

struct EnvironmentBuilderView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .environment(AuthManager(service: FirebaseAuthServices()))
            .environment(UserManager(services: ProductionUserServicesContainer()))
            .environment(AIManager(service: PollinationsAIService()))
    }
}

@main
struct AIChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            EnvironmentBuilderView {
                AppView()
            }
        }
    }
}
