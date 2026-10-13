//
//  WelcomeViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

@MainActor
@Observable
class WelcomeViewModel {
    private let interactor: WelcomeInteractor
    let imageName: String

    var showSignInView = false
    var navPathStack: [NavigationOnboardingPathOption] = []

    init(interactor: WelcomeInteractor, imageName: String = Constants.randomImage) {
        self.interactor = interactor
        self.imageName = imageName
    }

    func addToNavPathStack(route: NavigationOnboardingPathOption) {
        navPathStack.append(route)
    }

    func onGetStartedPressed() {
        interactor.trackEvent(event: WelcomeViewEvent.getStartedPressed)
        addToNavPathStack(route: .onboardingIntro)
    }

    func onSignInPressed() {
        interactor.trackEvent(event: WelcomeViewEvent.signInPressed)
        showSignInView = true
    }

    func onTermsOfServicePressed() {
        interactor.trackEvent(event: WelcomeViewEvent.termsOfServicePressed)
    }

    func onPrivacyPolicyPressed() {
        interactor.trackEvent(event: WelcomeViewEvent.privacyPolicyPressed)
    }

    func handleDidSignIn(isNewUser: Bool, onExistingUserSignedIn: () -> Void) {
        interactor.trackEvent(event: WelcomeViewEvent.signInCompleted(isNewUser: isNewUser))
        if !isNewUser {
            onExistingUserSignedIn()
        }
    }
}

extension WelcomeViewModel {
    enum WelcomeViewEvent: LoggableEvent {
        case getStartedPressed
        case signInPressed
        case termsOfServicePressed
        case privacyPolicyPressed
        case signInCompleted(isNewUser: Bool)

        var eventName: String {
            switch self {
            case .getStartedPressed:
                return "WelcomeView_GetStarted_Pressed"
            case .signInPressed:
                return "WelcomeView_SignIn_Pressed"
            case .termsOfServicePressed:
                return "WelcomeView_TermsOfService_Pressed"
            case .privacyPolicyPressed:
                return "WelcomeView_PrivacyPolicy_Pressed"
            case .signInCompleted:
                return "WelcomeView_SignInCompleted_Success"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signInCompleted(isNewUser: let isNewUser):
                return isNewUser.asEventParameter(key: "is_new_user")
            default:
                return nil
            }
        }

        var type: LogType {
            .analytic
        }
    }
}
