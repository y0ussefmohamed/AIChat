//
//  OnboardingCommunityViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import SwiftUI

@MainActor
@Observable
class OnboardingCommunityViewModel {
    private let interactor: OnboardingCommunityInteractor

    init(interactor: OnboardingCommunityInteractor) {
        self.interactor = interactor
    }

    func onContinueButtonPressed(onNavigate: (NavigationOnboardingPathOption) -> Void) {
        interactor.trackEvent(event: OnboardingCommunityViewEvent.continueButtonPressed)
        onNavigate(.colorView)
    }
}

extension OnboardingCommunityViewModel {
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
