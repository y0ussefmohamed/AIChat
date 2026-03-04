//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var rootAppState

    var body: some View {
        VStack {
            Text("Onboarding Completed!")
                .font(Font.title.bold())
                .foregroundStyle(.accent)
                .frame(maxHeight: .infinity)

            Button {
                onFinishButtonPressed()
            } label: {
                Text("Finish")
                    .callToActionButton()
            }
        }
        .navigationBarBackButtonHidden()
        .padding(16)
    }

    private func onFinishButtonPressed() {
        rootAppState.updateViewState(showTabBar: true)
    }
}



#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
