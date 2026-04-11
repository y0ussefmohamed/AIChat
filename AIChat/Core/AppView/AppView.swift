//
//  AppView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import SwiftUI

struct AppView: View {
    @Environment(\.authServices) private var authServices
    @State var appState: AppState = AppState()

    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
        })
        /// you can get access to this specific appState obj. using `@Envirnonment(AppState.self)`
        .environment(appState) /// this will be in the views that has `AppView` as parent/ancestor
        .task {
            await checkUserStatus()
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            /// if user signedOut\deletedAccount then make a new anonymous account
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }

    private func checkUserStatus() async {
        if let user = authServices.getAuthenticatedUser() {
            print("User is already authenticated: \(user.uid)")
        } else {
            do {
                let result = try await authServices.signInAnonymously()
                print("User is NEW, now authenticated: \(result.user.uid)")
            } catch {
                print(error)
            }
        }
    }
}

#Preview("Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}

#Preview("Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}
