//
//  WelcomeView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct WelcomeView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: WelcomeViewModel

    var body: some View {
        NavigationStack(path: $viewModel.navPathStack) {
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
            .navigationDestination(for: NavigationOnboardingPathOption.self) { route in
                switch route {
                case .onboardingIntro:
                    /// 1: pass a function that holds destination from this view
                    /// 2: put the destination from this view to next view in the viewmodel
                    /// 3: call current viewModel with this destination to add to stack
                    OnboardingIntroView(
                        viewModel: OnboardingIntroViewModel(
                            interactor: CoreInteractor(container: container)
                        ),
                        onNavigate: viewModel.addToNavPathStack
                    )

                case .colorView:
                    OnboardingColorView(
                        viewModel: OnboardingColorViewModel(
                            interactor: CoreInteractor(container: container)
                        ),
                        onNavigate: viewModel.addToNavPathStack
                    )

                case .communityView:
                    OnboardingCommunityView(
                        viewModel: OnboardingCommunityViewModel(
                            interactor: CoreInteractor(container: container)
                        ),
                        onNavigate: viewModel.addToNavPathStack
                    )

                case .completedView(let selectedColor):
                    OnboardingCompletedView(
                        viewModel: OnboardingCompletedViewModel(
                            interactor: CoreInteractor(container: container),
                            selectedColor: selectedColor
                        )
                    )
                }
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
            Button(action: viewModel.onGetStartedPressed) {
                Text("Get Started")
                    .callToActionButton()
            }
            .accessibilityIdentifier(AccessibilityID.Welcome.getStarted)
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
            viewModel.updateAppState(showTabBar: true)
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
