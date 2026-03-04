//
//  WelcomeView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to the Chat App 🎊")
                    .font(Font.title.bold())
                    .foregroundStyle(.accent)
                    .frame(maxHeight: .infinity)

                NavigationLink {
                    OnboardingCompletedView()
                } label: {
                    Text("Get Started")
                        .callToActionButton()
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppState())
}
