//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct OnboardingCompletedView: View {
    /// extracts the `AppState` type variable that was passed as an environment(`object`)
    @Environment(AppState.self) private var rootAppState
    @Environment(UserManager.self) private var userManager
    var selectedColor: Color = .accentColor

    @State private var isLoadingToSetupProfile: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Completed! 🎉")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)

            Text("We've set up your profile and you're ready to start chatting")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            AsyncCallToActionButton(title: "Finish", buttonColor: selectedColor, conditionToLoad: $isLoadingToSetupProfile) {
                onFinishButtonPressed()
            }
        }
        .padding(16)
    }
}

// MARK: - Seperate Business Logic out of Views
extension OnboardingCompletedView {
    private func onFinishButtonPressed() {
        isLoadingToSetupProfile = true

        Task {
            try await userManager.markOnboardingAsCompleted(profileColorHex: selectedColor.toHex())
            isLoadingToSetupProfile = false

            rootAppState.updateViewState(showTabBar: true)
        }
    }
}


#Preview {
    OnboardingCompletedView()
        .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
        .environment(AppState())
}
