//
//  WelcomeView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct WelcomeView: View {
    var imageName: String = Constants.randomImage

    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(imageUrlString: imageName)
                    .ignoresSafeArea()

                titleSection
                    .padding(.top, 16)

                ctaButtons

                policyLinks
                    .foregroundStyle(.accent)
            }
        }
    }
}

// MARK: - Sub Views
extension WelcomeView {
    private var titleSection: some View {
        VStack {
            Text("AI Chat 📱")
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
            .padding(.vertical, 8)
            .padding(.horizontal, 16)

            Text("Already have an account? Sign in.")
                .underline()
                .font(.body)
                .padding(8)
                .tappableBackground()
                .onTapGesture {

                }
        }
    }

    private var policyLinks: some View {
        HStack {
            Link(destination: Constants.termsOfServiceURL) {
                Text("Terms of Service")
            }

            Circle()
                .frame(width: 4, height: 4)

            Link(destination: Constants.privacyPolicyURL) {
                Text("Privacy Policy")
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environment(AppState())
}
