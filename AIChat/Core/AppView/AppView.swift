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
        .screenAppearAnalytics(viewName: "AppView")
        .task {
            await checkUserStatus()
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

    enum AppViewEvent: LoggableEvent {
        case existingAuthStart, existingAuthSuccess, existingAuthFail(error: Error)
        case anonymousAuthStart, anonymousAuthSuccess, anonymousAuthFail(error: Error)

        var eventName: String {
            switch self {
            case .existingAuthStart:
                return "AppView_ExistingAuthStart"
            case .existingAuthSuccess:
                return "AppView_ExistingAuthSuccess"
            case .existingAuthFail:
                return "AppView_ExistingAuthFail"
            case .anonymousAuthStart:
                return "AppView_AnonymousAuthStart"
            case .anonymousAuthSuccess:
                return "AppView_AnonymousAuthSuccess"
            case .anonymousAuthFail:
                return "AppView_AnonymousAuthFail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error):
                return error.asEventParameter
            case .anonymousAuthFail(error: let error):
                return error.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .existingAuthFail, .anonymousAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

    private func checkUserStatus() async {
        if let user = authManager.auth {
            logManager.trackEvent(event: AppViewEvent.existingAuthStart)
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
                logManager.trackEvent(event: AppViewEvent.existingAuthSuccess)
            } catch {
                logManager.trackEvent(event: AppViewEvent.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(2.5))
                await checkUserStatus()
            }

        } else {
            logManager.trackEvent(event: AppViewEvent.anonymousAuthStart)
            do {
                let result = try await authManager.signInAnonymously()
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)

                logManager.trackEvent(event: AppViewEvent.anonymousAuthSuccess)
            } catch {
                logManager.trackEvent(event: AppViewEvent.anonymousAuthFail(error: error))
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
