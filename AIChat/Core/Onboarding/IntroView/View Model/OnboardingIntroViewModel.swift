//
//  OnboardingIntroViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

@MainActor
@Observable
class OnboardingIntroViewModel {
    private let interactor: OnboardingIntroInteractor

    private var nextStepOnRoute: NavigationOnboardingPathOption {
        interactor.activeTests.onboardingCommunityTest ?
            .communityView : .colorView
    }

    init(interactor: OnboardingIntroInteractor) {
        self.interactor = interactor
    }

    func onContinueButtonPressed(onNavigate: (NavigationOnboardingPathOption) -> Void) {
        interactor.trackEvent(event: OnboardingIntroViewEvent.continueButtonPressed)
        onNavigate(nextStepOnRoute)
    }
}

extension OnboardingIntroViewModel {
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
