//
//  OnboardingColorView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

struct OnboardingColorView: View {
    @State var viewModel: OnboardingColorViewModel
    var onNavigate: (NavigationOnboardingPathOption) -> Void

    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .screenAppearAnalytics(viewName: "OnboardingColorView")
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16) {
            if let selectedColor = viewModel.selectedColor {
                ZStack {
                    ctaButton(selectedColor: selectedColor)
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
                    ForEach(viewModel.profileColors.indices, id: \.self) { colorIdx in
                        Button {
                            onColorSelected(index: colorIdx)
                        } label: {
                            Circle()
                                .fill(.accent)
                                .overlay(
                                    Circle()
                                        .fill(viewModel.profileColors[colorIdx])
                                        .padding(viewModel.selectedColorIdx == colorIdx ? 10 : 0)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(AccessibilityID.Onboarding.color(colorIdx))
                        .accessibilityLabel(viewModel.profileColorNames[colorIdx])
                        .accessibilityValue(viewModel.selectedColorIdx == colorIdx ? "Selected" : "Not selected")
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
            viewModel.onColorSelected(index: index)
        }
    }

    private func ctaButton(selectedColor: Color) -> some View {
        Button {
            viewModel.onContinueButtonPressed(onNavigate: onNavigate)
        } label: {
            Text("Continue")
                .callToActionButton(buttonColor: selectedColor)
                .padding(16)
        }
        .accessibilityIdentifier(AccessibilityID.Onboarding.colorContinue)
    }
}

#Preview {
    let container = DevPreview.shared.container
    let logManager = LogManager(services: [ConsoleService()])
    container.register(LogManager.self, service: logManager)

    return OnboardingColorView(
        viewModel: OnboardingColorViewModel(interactor: CoreInteractor(container: container)),
        onNavigate: { _ in }
    )
    .previewEnvironment()
    .environment(container)
    .environment(logManager)
}
