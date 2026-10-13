//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

struct OnboardingIntroView: View {
    @State var viewModel: OnboardingIntroViewModel
    var onNavigate: (NavigationOnboardingPathOption) -> Void

    var body: some View {
        VStack {
            VStack {
                Text("Make your own ")
                +
                Text("avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chat with them!\n\nHave ")
                +
                Text("real conversations ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("with AI generated responses")
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(AccessibilityID.Onboarding.intro)
            .frame(maxHeight: .infinity)

            ctaButton
        }
        .screenAppearAnalytics(viewName: "OnboardingIntroView")
        .navigationBarBackButtonHidden()
        .padding(16)
        .font(.title3)
    }
}

extension OnboardingIntroView {
    private var ctaButton: some View {
        Button {
            viewModel.onContinueButtonPressed(onNavigate: onNavigate)
        } label: {
            Text("Continue")
                .callToActionButton()
        }
        .accessibilityIdentifier(AccessibilityID.Onboarding.introContinue)
    }
}

#Preview("Original") {
    let container = DevPreview.shared.container
    let logManager = LogManager(services: [ConsoleService()])
    container.register(LogManager.self, service: logManager)
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: false)))

    return OnboardingIntroView(
        viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)),
        onNavigate: { _ in }
    )
    .previewEnvironment()
    .environment(container)
    .environment(logManager)
}

#Preview("Onboarding AB Test") {
    let container = DevPreview.shared.container
    let logManager = LogManager(services: [ConsoleService()])
    container.register(LogManager.self, service: logManager)
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(onboardingCommunityTest: true)))

    return OnboardingIntroView(
        viewModel: OnboardingIntroViewModel(interactor: CoreInteractor(container: container)),
        onNavigate: { _ in }
    )
    .previewEnvironment()
    .environment(container)
    .environment(logManager)
}
