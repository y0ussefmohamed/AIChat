//
//  OnboardingCompletedViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

@MainActor
@Observable
class OnboardingCompletedViewModel {
    private let interactor: OnboardingCompletedInteractor
    let selectedColor: Color

    private(set) var isLoadingToSetupProfile = false

    var alert: AnyAppAlert?

    var selectedColorHex: String {
        selectedColor.toHex()
    }

    init(interactor: OnboardingCompletedInteractor, selectedColor: Color = .accentColor) {
        self.interactor = interactor
        self.selectedColor = selectedColor
    }

    func updateAppState(showTabBar: Bool) {
        interactor.updateAppState(showTabBar: showTabBar)
    }

    func onFinishButtonPressed(onCompleted: @escaping () -> Void) {
        guard !isLoadingToSetupProfile else { return }
        let hex = selectedColorHex
        interactor.trackEvent(event: OnboardingCompletedViewEvent.finishStart(colorHex: hex))
        isLoadingToSetupProfile = true

        Task {
            defer { isLoadingToSetupProfile = false }
            do {
                try await interactor.markOnboardingAsCompleted(profileColorHex: hex)
                interactor.trackEvent(event: OnboardingCompletedViewEvent.finishSuccess(colorHex: hex))
                onCompleted()
            } catch {
                interactor.trackEvent(event: OnboardingCompletedViewEvent.finishFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }
}

extension OnboardingCompletedViewModel {
    enum OnboardingCompletedViewEvent: LoggableEvent {
        case finishStart(colorHex: String)
        case finishSuccess(colorHex: String)
        case finishFail(error: Error)

        var eventName: String {
            switch self {
            case .finishStart:
                return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:
                return "OnboardingCompletedView_Finish_Success"
            case .finishFail:
                return "OnboardingCompletedView_Finish_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .finishStart(colorHex: let hex),
                 .finishSuccess(colorHex: let hex):
                return hex.asEventParameter(key: "profile_color_hex")
            case .finishFail(error: let error):
                return error.asEventParameter
            }
        }

        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
