//
//  AppView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import SwiftUI
import SwiftfulUtilities

struct AppView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @State var appState: AppState = AppState()

    var body: some View {
        RootView(
            delegate: RootDelegate(
                onApplicationDidAppear: nil,
                onApplicationWillEnterForeground: { _ in
                    Task {
                        await checkUserStatus()
                    }
                },
                onApplicationDidBecomeActive: nil,
                onApplicationWillResignActive: nil,
                onApplicationDidEnterBackground: nil,
                onApplicationWillTerminate: nil)
        ) {
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
            .task {
                try? await Task.sleep(for: .seconds(2))
                await showATTPromptIfNeeded()
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
    }

    private func showATTPromptIfNeeded() async {
        #if !DEBUG
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        logManager.trackEvent(event: AppViewEvent.attStatus(params: status.eventParameters))
        #endif
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

extension AppView {
    enum AppViewEvent: LoggableEvent {
        case attStatus(params: [String: Any])
        case existingAuthStart, existingAuthSuccess, existingAuthFail(error: Error)
        case anonymousAuthStart, anonymousAuthSuccess, anonymousAuthFail(error: Error)

        var eventName: String {
            switch self {
            case .attStatus:
                return "AppView_AttStatus"
            case .existingAuthStart:
                return "AppView_ExistingAuth_Start"
            case .existingAuthSuccess:
                return "AppView_ExistingAuth_Success"
            case .existingAuthFail:
                return "AppView_ExistingAuth_Fail"
            case .anonymousAuthStart:
                return "AppView_AnonymousAuth_Start"
            case .anonymousAuthSuccess:
                return "AppView_AnonymousAuth_Success"
            case .anonymousAuthFail:
                return "AppView_AnonymousAuth_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .attStatus(params: let params):
                return params
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
}

#Preview("Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .previewEnvironment()
}


#Preview("Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .previewEnvironment()
}
