//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @State var viewModel: OnboardingCompletedViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Completed! 🎉")
                .accessibilityIdentifier(AccessibilityID.Onboarding.completed)
                .accessibilityValue(viewModel.selectedColorHex)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(viewModel.selectedColor)

            Text("We've set up your profile and you're ready to start chatting")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .screenAppearAnalytics(viewName: "OnboardingCompletedView")
        .safeAreaInset(edge: .bottom) {
            AsyncCallToActionButton(title: "Finish", buttonColor: viewModel.selectedColor, conditionToLoad: .constant(viewModel.isLoadingToSetupProfile)) {
                viewModel.onFinishButtonPressed {
                    viewModel.updateAppState(showTabBar: true)
                }
            }
            .accessibilityIdentifier(AccessibilityID.Onboarding.finish)
        }
        .showCustomAlert(alert: $viewModel.alert)
        .padding(16)
    }
}

#Preview {
    let container = DevPreview.shared.container
    let logManager = LogManager(services: [ConsoleService()])
    container.register(LogManager.self, service: logManager)
    container.register(UserManager.self, service: UserManager(services: MockUserServicesContainer(user: .mock)))

    return OnboardingCompletedView(
        viewModel: OnboardingCompletedViewModel(interactor: CoreInteractor(container: container))
    )
    .previewEnvironment()
    .environment(container)
    .environment(logManager)
}
