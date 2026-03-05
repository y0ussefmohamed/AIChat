//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

struct OnboardingIntroView: View {
    var body: some View {
        NavigationStack {
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
                .frame(maxHeight: .infinity)


                ctaButton
            }
            .navigationBarBackButtonHidden()
            .padding(16)
            .font(.title3)
        }
    }
}

extension OnboardingIntroView {
    private var ctaButton: some View {
        NavigationLink {
            OnboardingColorView()
        } label: {
            Text("Continue")
                .callToActionButton()
        }
    }
}

#Preview {
    OnboardingIntroView()
}
