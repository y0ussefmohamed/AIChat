//
//  LinkProviderViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 11/03/2026.
//

import SwiftUI

enum LinkProviderViewOptions: String {
    case signIn
    case createAccount

    var title: String {
        switch self {
        case .signIn:
            return "Sign In"
        case .createAccount:
            return "Create Account"
        }
    }

    var ctaButtonTitle: String {
        switch self {
        case .signIn:
            "Sign In"
        case .createAccount:
            "Sign Up"
        }
    }

    var asEventParameter: [String: Any] {
        return ["title": title]
    }
}

@MainActor
@Observable
class LinkProviderViewModel {
    private let interactor: LinkProviderInteractor

    var usageOption: LinkProviderViewOptions
    var fullName = ""
    var email = ""
    var password = ""
    var isPasswordVisible = false
    var showAlert: AnyAppAlert?

    init(interactor: LinkProviderInteractor, usageOption: LinkProviderViewOptions) {
        self.interactor = interactor
        self.usageOption = usageOption
    }

    func onSwitchModePressed() {
        let targetOption: LinkProviderViewOptions = usageOption == .createAccount ? .signIn : .createAccount
        interactor.trackEvent(event: LinkProviderViewEvent.switchModePressed(to: targetOption))
        usageOption = targetOption
    }

    func onSignInApple(onDidSignIn: @escaping (Bool) -> Void) {
        interactor.trackEvent(event: LinkProviderViewEvent.signInAppleStart)

        Task {
            do {
                let authInfo = try await interactor.signInApple()

                try await interactor.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)
                let currentUser = interactor.currentUser

                interactor.trackEvent(event: LinkProviderViewEvent.signInAppleSuccess(user: currentUser, isNewUser: authInfo.isNewUser))

                onDidSignIn(authInfo.isNewUser)
            } catch {
                interactor.trackEvent(event: LinkProviderViewEvent.signInAppleFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    func signInEmail(onDidSignIn: @escaping (Bool) -> Void) {
        interactor.trackEvent(event: LinkProviderViewEvent.signInEmailStart)

        Task {
            do {
                let authInfo = try await interactor.signInEmail(email: email, password: password)
                try await interactor.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)

                let currentUser = interactor.currentUser
                interactor.trackEvent(event: LinkProviderViewEvent.signInEmailSuccess(user: currentUser, isNewUser: authInfo.isNewUser))

                onDidSignIn(authInfo.isNewUser)
            } catch {
                interactor.trackEvent(event: LinkProviderViewEvent.signInEmailFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    func createAccountEmail(onDidSignIn: @escaping (Bool) -> Void) {
        interactor.trackEvent(event: LinkProviderViewEvent.createAccountEmailStart)

        Task {
            do {
                let authInfo = try await interactor.createAccountEmail(email: email, password: password)
                try await interactor.logIn(auth: authInfo.user, isNewUser: authInfo.isNewUser)

                let currentUser = interactor.currentUser
                interactor.trackEvent(event: LinkProviderViewEvent.createAccountEmailSuccess(user: currentUser, isNewUser: authInfo.isNewUser))

                onDidSignIn(authInfo.isNewUser)
            } catch {
                interactor.trackEvent(event: LinkProviderViewEvent.createAccountEmailFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    func signingActionMethod(onDidSignIn: @escaping (Bool) -> Void) {
        switch usageOption {
        case .signIn:
            signInEmail(onDidSignIn: onDidSignIn)
        case .createAccount:
            createAccountEmail(onDidSignIn: onDidSignIn)
        }
    }
}

extension LinkProviderViewModel {
    enum LinkProviderViewEvent: LoggableEvent {
        case switchModePressed(to: LinkProviderViewOptions)
        case signInAppleStart, signInAppleSuccess(user: UserModel?, isNewUser: Bool), signInAppleFail(error: Error)
        case signInEmailStart, signInEmailSuccess(user: UserModel?, isNewUser: Bool), signInEmailFail(error: Error)
        case createAccountEmailStart, createAccountEmailSuccess(user: UserModel?, isNewUser: Bool), createAccountEmailFail(error: Error)

        var eventName: String {
            switch self {
            case .switchModePressed:
                return "LinkProviderView_SwitchMode_Pressed"
            case .signInAppleStart:
                return "LinkProviderView_SignInApple_Start"
            case .signInAppleSuccess:
                return "LinkProviderView_SignInApple_Success"
            case .signInAppleFail:
                return "LinkProviderView_SignInApple_Fail"
            case .signInEmailStart:
                return "LinkProviderView_SignInEmail_Start"
            case .signInEmailSuccess:
                return "LinkProviderView_SignInEmail_Success"
            case .signInEmailFail:
                return "LinkProviderView_SignInEmail_Fail"
            case .createAccountEmailStart:
                return "LinkProviderView_CreateAccountEmail_Start"
            case .createAccountEmailSuccess:
                return "LinkProviderView_CreateAccountEmail_Success"
            case .createAccountEmailFail:
                return "LinkProviderView_CreateAccountEmail_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .switchModePressed(to: let option):
                return option.asEventParameter

            case .signInAppleSuccess(user: let user, isNewUser: let isNewUser),
                 .signInEmailSuccess(user: let user, isNewUser: let isNewUser),
                 .createAccountEmailSuccess(user: let user, isNewUser: let isNewUser):
                return (user?.asEventParameter ?? [:])
                    .merged(isNewUser.asEventParameter(key: "is_new_user"))

            case .signInAppleFail(error: let error),
                 .signInEmailFail(error: let error),
                 .createAccountEmailFail(error: let error):
                return error.asEventParameter

            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .signInAppleFail, .signInEmailFail, .createAccountEmailFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
