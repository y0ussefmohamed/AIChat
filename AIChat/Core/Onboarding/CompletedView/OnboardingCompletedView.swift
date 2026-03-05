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

    var body: some View {
        VStack {
            Text("Onboarding Completed! 🎉")
                .font(Font.title.bold())
                .foregroundStyle(.accent)
                .frame(maxHeight: .infinity)

            Button(action: onFinishButtonPressed) {
                Text("Finish")
                    .callToActionButton()
                    .padding(16)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Seperate Business Logic out of Views
extension OnboardingCompletedView {
    private func onFinishButtonPressed() {
        rootAppState.updateViewState(showTabBar: true)
    }
}


#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
