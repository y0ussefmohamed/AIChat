//
//  OnboardingColorViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

@MainActor
@Observable
class OnboardingColorViewModel {
    private let interactor: OnboardingColorInteractor

    let profileColors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]
    let profileColorNames = ["Red", "Green", "Orange", "Blue", "Mint", "Purple", "Cyan", "Teal", "Indigo"]

    private(set) var selectedColorIdx: Int?

    var selectedColor: Color? {
        guard let selectedColorIdx, profileColors.indices.contains(selectedColorIdx) else { return nil }
        return profileColors[selectedColorIdx]
    }

    init(interactor: OnboardingColorInteractor) {
        self.interactor = interactor
    }

    func onColorSelected(index: Int) {
        guard profileColors.indices.contains(index) else { return }
        selectedColorIdx = index
    }

    func onContinueButtonPressed(onNavigate: (NavigationOnboardingPathOption) -> Void) {
        guard let selectedColor else { return }
        let hex = selectedColor.toHex()
        interactor.trackEvent(event: OnboardingColorViewEvent.continueButtonPressed(hex: hex))
        onNavigate(.completedView(selectedColor: selectedColor))
    }
}

extension OnboardingColorViewModel {
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
