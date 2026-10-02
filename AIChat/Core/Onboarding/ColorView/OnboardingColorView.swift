//
//  OnboardingColorView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

struct OnboardingColorView: View {
    @Environment(LogManager.self) private var logManager
    @State private var selectedColorIdx: Int?
    let profileColors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]
    private let profileColorNames = ["Red", "Green", "Orange", "Blue", "Mint", "Purple", "Cyan", "Teal", "Indigo"]

    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .screenAppearAnalytics(viewName: "OnboardingColorView")
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16) {
            if let selectedColorIdx {
                ZStack {
                    ctaButton(selectedColor: profileColors[selectedColorIdx])
                        .background(Color(.systemBackground))
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}

extension OnboardingColorView {
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section(content: {
                    ForEach(profileColors.indices, id: \.self) { colorIdx in
                        Button {
                            onColorSelected(index: colorIdx)
                        } label: {
                            Circle()
                                .fill(.accent)
                                .overlay(
                                    Circle()
                                        .fill(profileColors[colorIdx])
                                        .padding(selectedColorIdx == colorIdx ? 10 : 0)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(AccessibilityID.Onboarding.color(colorIdx))
                        .accessibilityLabel(profileColorNames[colorIdx])
                        .accessibilityValue(selectedColorIdx == colorIdx ? "Selected" : "Not selected")
                    }
                }, header: {
                    Text("Select a Profile Color")
                        .accessibilityIdentifier(AccessibilityID.Onboarding.colorTitle)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                })
            }
        )
    }

    private func onColorSelected(index: Int) {
        withAnimation(.bouncy) {
            selectedColorIdx = index
        }
    }

    private func ctaButton(selectedColor: Color) -> some View {
        NavigationLink {
            OnboardingCompletedView(selectedColor: selectedColor)
        } label: {
            Text("Continue")
                .callToActionButton(buttonColor: selectedColor)
                .padding(16)
        }
        .accessibilityIdentifier(AccessibilityID.Onboarding.colorContinue)
        .simultaneousGesture(TapGesture().onEnded {
            let hex = selectedColor.toHex()
            logManager.trackEvent(event: OnboardingColorViewEvent.continueButtonPressed(hex: hex))
        })
    }
}

extension OnboardingColorView {
    enum OnboardingColorViewEvent: LoggableEvent {
        case continueButtonPressed(hex: String)

        var eventName: String {
            switch self {
            case .continueButtonPressed:
                return "OnboardingColorView_Continue_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .continueButtonPressed(hex: let hex):
                return hex.asEventParameter(key: "profile_color_hex")
            }
        }

        var type: LogType {
            .analytic
        }
    }
}

#Preview {
    OnboardingColorView()
        .environment(LogManager(services: [ConsoleService()]))
}
