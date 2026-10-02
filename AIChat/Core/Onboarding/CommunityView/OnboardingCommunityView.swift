//
//  OnboardingCommunityView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import SwiftUI

struct OnboardingCommunityView: View {
    @Environment(LogManager.self) private var logManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    communityIllustration

                    VStack(alignment: .leading, spacing: 12) {
                        Text("WELCOME TO THE COMMUNITY")
                            .accessibilityIdentifier(AccessibilityID.Onboarding.community)
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(2)
                            .foregroundStyle(.accent)

                        Text("A new world of conversations awaits.")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Discover AI characters with their own personalities, start a chat, or create an avatar that is entirely yours.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    HStack(spacing: 10) {
                        Label("Discover", systemImage: "sparkles")
                        Label("Chat", systemImage: "bubble.left.fill")
                        Label("Create", systemImage: "plus.circle.fill")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
                }
                .frame(maxWidth: 480, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(16)
            }
            .screenAppearAnalytics(viewName: "OnboardingCommunityView")
            .navigationBarBackButtonHidden()
            .safeAreaInset(edge: .bottom) {
                ctaButton
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
            }
        }
    }
}

private extension OnboardingCommunityView {
    var communityIllustration: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.accentColor.opacity(0.10))

            Circle()
                .strokeBorder(Color.accentColor.opacity(0.18), lineWidth: 2)
                .frame(width: 230, height: 230)

            Circle()
                .fill(Color.accentColor.opacity(0.12))
                .frame(width: 160, height: 160)

            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 66))
                .foregroundStyle(.accent)
                .accessibilityHidden(true)

            CommunityIcon(systemName: "person.fill", color: .purple)
                .offset(x: -95, y: -74)

            CommunityIcon(systemName: "person.fill", color: .orange)
                .offset(x: 100, y: -66)

            CommunityIcon(systemName: "sparkles", color: .accentColor)
                .offset(x: 78, y: 88)
        }
        .frame(height: 290)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("AI characters gathered around a conversation")
        .accessibilityAddTraits(.isImage)
        .accessibilityIdentifier(AccessibilityID.Onboarding.communityIllustration)
    }

    var ctaButton: some View {
        NavigationLink {
            OnboardingColorView()
        } label: {
            Text("Continue")
                .callToActionButton()
        }
        .accessibilityIdentifier(AccessibilityID.Onboarding.communityContinue)
        .simultaneousGesture(TapGesture().onEnded {
            onContinueButtonPressed()
        })
    }

    func onContinueButtonPressed() {
        logManager.trackEvent(event: OnboardingCommunityViewEvent.continueButtonPressed)
    }
}

private struct CommunityIcon: View {
    let systemName: String
    let color: Color

    var body: some View {
        Image(systemName: systemName)
            .font(.title2)
            .foregroundStyle(color)
            .frame(width: 60, height: 60)
            .background(Color(.secondarySystemBackground), in: Circle())
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            .accessibilityHidden(true)
    }
}

extension OnboardingCommunityView {
    enum OnboardingCommunityViewEvent: LoggableEvent {
        case continueButtonPressed

        var eventName: String {
            switch self {
            case .continueButtonPressed:
                return "OnboardingCommunityView_Continue_Pressed"
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
    OnboardingCommunityView()
        .environment(LogManager(services: [ConsoleService()]))
}
