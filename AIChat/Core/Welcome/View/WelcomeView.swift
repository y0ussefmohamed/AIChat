//
//  WelcomeView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(AppState.self) private var rootAppState
    @State var viewModel: WelcomeViewModel

    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(imageUrlString: viewModel.imageName)
                    .ignoresSafeArea()

                titleSection
                    .padding(.top, 16)

                ctaButtons

                policyLinks
                    .foregroundStyle(.accent)
            }
            .screenAppearAnalytics(viewName: "WelcomeView")
            .sheet(isPresented: $viewModel.showSignInView) {
                LinkProviderView(
                    viewModel: LinkProviderViewModel(
                        interactor: CoreInteractor(container: container),
                        usageOption: .signIn
                    ),
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
                .accessibilityIdentifier(AccessibilityID.Welcome.title)
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
            .accessibilityIdentifier(AccessibilityID.Welcome.getStarted)
            .simultaneousGesture(TapGesture().onEnded {
                viewModel.onGetStartedPressed()
            })
            .padding(.vertical, 8)
            .padding(.horizontal, 16)

            Text("Already have an account? Sign in.")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .styledButton {
                    viewModel.onSignInPressed()
                }
                .accessibilityIdentifier(AccessibilityID.Welcome.signIn)
        }
    }

    private func handleDidSignIn(isNewUser: Bool) {
        viewModel.handleDidSignIn(isNewUser: isNewUser) {
            rootAppState.updateViewState(showTabBar: true)
        }
    }

    private var policyLinks: some View {
        HStack {
            Link(destination: Constants.termsOfServiceURL) {
                Text("Terms of Service")
            }
            .accessibilityIdentifier(AccessibilityID.Welcome.terms)
            .simultaneousGesture(TapGesture().onEnded {
                viewModel.onTermsOfServicePressed()
            })

            Circle()
                .frame(width: 4, height: 4)

            Link(destination: Constants.privacyPolicyURL) {
                Text("Privacy Policy")
            }
            .accessibilityIdentifier(AccessibilityID.Welcome.privacy)
            .simultaneousGesture(TapGesture().onEnded {
                viewModel.onPrivacyPolicyPressed()
            })
        }
    }
}

#Preview {
    let container = DevPreview.shared.container
    let logManager = LogManager(services: [ConsoleService()])
    container.register(LogManager.self, service: logManager)

    return WelcomeView(viewModel: WelcomeViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvironment()
        .environment(container)
        .environment(logManager)
}
