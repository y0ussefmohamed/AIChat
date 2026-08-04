//
//  AppView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import SwiftUI

struct AppView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
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
        .onAppear {
            for event in EventExample.allCases {
                logManager.trackEvent(event: event)
            }
        }
        .onChange(of: appState.showTabBar) { _, showTabBar in
            /// if user signedOut\deletedAccount then create a new anonymous account
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        }
    }

    private func checkUserStatus() async {
        if let user = authManager.auth {
            print("User is already authenticated: \(user.uid)")
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                print(error)
                try? await Task.sleep(for: .seconds(2.5))
                await checkUserStatus()
            }

        } else {
            do {
                let result = try await authManager.signInAnonymously()
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)

                print("User is NEW, now authenticated: \(result.user.uid)")
            } catch {
                print(error)
                try? await Task.sleep(for: .seconds(2.5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .previewEnvironment()
}


#Preview("Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .previewEnvironment()
}
