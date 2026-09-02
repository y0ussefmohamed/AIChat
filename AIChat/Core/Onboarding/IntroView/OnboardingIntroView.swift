//
//  OnboardingIntroView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

struct OnboardingIntroView: View {
    @Environment(LogManager.self) private var logManager

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
            .screenAppearAnalytics(viewName: "OnboardingIntroView")
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
        .simultaneousGesture(TapGesture().onEnded {
            onContinueButtonPressed()
        })
    }

    private func onContinueButtonPressed() {
        logManager.trackEvent(event: OnboardingIntroViewEvent.continueButtonPressed)
    }
}

extension OnboardingIntroView {
    enum OnboardingIntroViewEvent: LoggableEvent {
        case continueButtonPressed

        var eventName: String {
            switch self {
            case .continueButtonPressed:
                return "OnboardingIntroView_Continue_Pressed"
            }
        }

        var parameters: [String: Any]? {
            nil
        }

        var type: LogType {
            .analytic
        }
    }
}

#Preview {
    OnboardingIntroView()
        .environment(LogManager(services: [ConsoleService()]))
}
