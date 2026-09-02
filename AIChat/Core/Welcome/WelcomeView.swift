//
//  WelcomeView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AppState.self) private var rootAppState
    @State private var showSignInView: Bool = false
    @State var imageName: String = Constants.randomImage

    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(imageUrlString: imageName)
                    .ignoresSafeArea()

                titleSection
                    .padding(.top, 16)

                ctaButtons

                policyLinks
                    .foregroundStyle(.accent)
            }
            .screenAppearAnalytics(viewName: "WelcomeView")
            .sheet(isPresented: $showSignInView) {
                LinkProviderView(
                    usageOption: .signIn,
                    onDidSignIn: handleDidSignIn
                )
            }
        }
    }
}

// MARK: - Sub Views
extension WelcomeView {
    private var titleSection: some View {
        VStack {
            Text("AI Chat 📱")
                .font(Font.title.bold())
                .foregroundStyle(.black)

            Text("OpenAI Chatbots with SwiftUI")
                .font(Font.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var ctaButtons: some View {
        VStack {
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get Started")
                    .callToActionButton()
            }
            .simultaneousGesture(TapGesture().onEnded {
                onGetStartedPressed()
            })
            .padding(.vertical, 8)
            .padding(.horizontal, 16)

            Text("Already have an account? Sign in.")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .styledButton {
                    onSignInPressed()
                }
        }
    }

    /// if this user not first time to signIn the app, then showTabBar directly... no onboarding
    private func handleDidSignIn(isNewUser: Bool) {
        logManager.trackEvent(event: WelcomeViewEvent.signInCompleted(isNewUser: isNewUser))
        if !isNewUser {
            rootAppState.updateViewState(showTabBar: true)
        }
    }

    private func onGetStartedPressed() {
        logManager.trackEvent(event: WelcomeViewEvent.getStartedPressed)
    }

    private func onSignInPressed() {
        logManager.trackEvent(event: WelcomeViewEvent.signInPressed)
        showSignInView = true
    }

    private var policyLinks: some View {
        HStack {
            Link(destination: Constants.termsOfServiceURL) {
                Text("Terms of Service")
            }
            .simultaneousGesture(TapGesture().onEnded {
                logManager.trackEvent(event: WelcomeViewEvent.termsOfServicePressed)
            })

            Circle()
                .frame(width: 4, height: 4)

            Link(destination: Constants.privacyPolicyURL) {
                Text("Privacy Policy")
            }
            .simultaneousGesture(TapGesture().onEnded {
                logManager.trackEvent(event: WelcomeViewEvent.privacyPolicyPressed)
            })
        }
    }
}

extension WelcomeView {
    enum WelcomeViewEvent: LoggableEvent {
        case getStartedPressed
        case signInPressed
        case termsOfServicePressed
        case privacyPolicyPressed
        case signInCompleted(isNewUser: Bool)

        var eventName: String {
            switch self {
            case .getStartedPressed:
                return "WelcomeView_GetStarted_Pressed"
            case .signInPressed:
                return "WelcomeView_SignIn_Pressed"
            case .termsOfServicePressed:
                return "WelcomeView_TermsOfService_Pressed"
            case .privacyPolicyPressed:
                return "WelcomeView_PrivacyPolicy_Pressed"
            case .signInCompleted:
                return "WelcomeView_SignInCompleted_Success"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signInCompleted(isNewUser: let isNewUser):
                return isNewUser.asEventParameter(key: "is_new_user")
            default:
                return nil
            }
        }

        var type: LogType {
            .analytic
        }
    }
}

#Preview {
    WelcomeView()
        .environment(LogManager(services: [ConsoleService()]))
        .environment(AppState())
        .previewEnvironment()
}
