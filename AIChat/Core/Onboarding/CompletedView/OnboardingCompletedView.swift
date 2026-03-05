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
    var selectedColor: Color?

    @State private var isLoadingToSetupProfile: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Completed! 🎉")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor ?? .accent)

            Text("We've set up your profile and you're ready to start chatting")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            Button(action: onFinishButtonPressed) {
                ZStack {
                    if isLoadingToSetupProfile {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Finish")
                    }
                }
                .callToActionButton(buttonColor: selectedColor ?? .accent)
            }
            .disabled(isLoadingToSetupProfile)
        }
        .padding(16)
    }
}

// MARK: - Seperate Business Logic out of Views
extension OnboardingCompletedView {
    private func onFinishButtonPressed() {
        isLoadingToSetupProfile = true

        Task {
            try? await Task.sleep(for: .seconds(3))
            isLoadingToSetupProfile = false

            rootAppState.updateViewState(showTabBar: true)
        }


    }
}


#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
