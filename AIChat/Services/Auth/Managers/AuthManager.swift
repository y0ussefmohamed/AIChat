//
//  AuthManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/04/2026.
//

import Foundation
import SwiftUI
import Combine
import SwiftfulUtilities

@MainActor
@Observable /// `@Observable` class means we can have instance from this class in an environment scope we choose
class AuthManager {
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?
    let logManager: LogManager?

    init(service: AuthService, logManager: LogManager? = nil) {
        self.service = service
        self.auth = service.getAuthenticatedUser()
        self.logManager = logManager

        self.addAuthListener()
    }

    enum AuthManagerEvent: LoggableEvent {
        case signInAnonymousStart, signInAnonymousSuccess(user: UserAuthInfo, isNewUser: Bool), signInAnonymousFail(error: Error)
        case signInAppleStart, signInAppleSuccess(user: UserAuthInfo, isNewUser: Bool), signInAppleFail(error: Error)
        case signInEmailStart, signInEmailSuccess(user: UserAuthInfo, isNewUser: Bool), signInEmailFail(error: Error)
        case createAccountEmailStart, createAccountEmailSuccess(user: UserAuthInfo, isNewUser: Bool), createAccountEmailFail(error: Error)
        case signOutSuccess(user: UserAuthInfo?), signOutFail(error: Error)
        case deleteAccountStart(user: UserAuthInfo?), deleteAccountSuccess, deleteAccountFail(error: Error)

        var eventName: String {
            switch self {
            case .signInAnonymousStart:
                return "AuthManager_SignInAnonymous_Start"
            case .signInAnonymousSuccess:
                return "AuthManager_SignInAnonymous_Success"
            case .signInAnonymousFail:
                return "AuthManager_SignInAnonymous_Fail"
            case .signInAppleStart:
                return "AuthManager_SignInApple_Start"
            case .signInAppleSuccess:
                return "AuthManager_SignInApple_Success"
            case .signInAppleFail:
                return "AuthManager_SignInApple_Fail"
            case .signInEmailStart:
                return "AuthManager_SignInEmail_Start"
            case .signInEmailSuccess:
                return "AuthManager_SignInEmail_Success"
            case .signInEmailFail:
                return "AuthManager_SignInEmail_Fail"
            case .createAccountEmailStart:
                return "AuthManager_CreateAccountEmail_Start"
            case .createAccountEmailSuccess:
                return "AuthManager_CreateAccountEmail_Success"
            case .createAccountEmailFail:
                return "AuthManager_CreateAccountEmail_Fail"
            case .signOutSuccess:
                return "AuthManager_SignOut_Success"
            case .signOutFail:
                return "AuthManager_SignOut_Fail"
            case .deleteAccountStart:
                return "AuthManager_DeleteAccount_Start"
            case .deleteAccountSuccess:
                return "AuthManager_DeleteAccount_Success"
            case .deleteAccountFail:
                return "AuthManager_DeleteAccount_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signInAnonymousSuccess(user: let user, isNewUser: let isNewUser),
                 .signInAppleSuccess(user: let user, isNewUser: let isNewUser),
                 .signInEmailSuccess(user: let user, isNewUser: let isNewUser),
                 .createAccountEmailSuccess(user: let user, isNewUser: let isNewUser):
                return user.asEventParameter
                    .merged(isNewUser.asEventParameter(key: "is_new_user"))

            case .signOutSuccess(user: let user),
                 .deleteAccountStart(user: let user):
                return user?.asEventParameter

            case .signInAnonymousFail(error: let error),
                 .signInAppleFail(error: let error),
                 .signInEmailFail(error: let error),
                 .createAccountEmailFail(error: let error),
                 .signOutFail(error: let error),
                 .deleteAccountFail(error: let error):
                return error.asEventParameter

            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .signInAnonymousFail,
                 .signInAppleFail,
                 .signInEmailFail,
                 .createAccountEmailFail,
                 .signOutFail,
                 .deleteAccountFail:
                return .warning
            default:
                return .analytic
            }
        }
    }

    private func addAuthListener() {
        Task {
            for await value in service.addAuthenticatedUserListener(action: { listner in
                self.listener = listner
            }) {
                self.auth = value

                if let value {
                    logManager?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(properties: value.asEventParameter, isHighPriority: true)
                    logManager?.addUserProperties(properties: Utilities.eventParameters, isHighPriority: false)
                }
            }
        }
    }

    func getAuthId() throws -> String {
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
        }
        return uid
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        logManager?.trackEvent(event: AuthManagerEvent.signInAnonymousStart)

        do {
            let result = try await service.signInAnonymously()
            self.auth = result.user

            logManager?.trackEvent(event: AuthManagerEvent.signInAnonymousSuccess(user: result.user, isNewUser: result.isNewUser))
            return result
        } catch {
            logManager?.trackEvent(event: AuthManagerEvent.signInAnonymousFail(error: error))
            throw error
        }
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        logManager?.trackEvent(event: AuthManagerEvent.signInAppleStart)

        do {
            let result = try await service.signInApple()
            self.auth = result.user

            logManager?.trackEvent(event: AuthManagerEvent.signInAppleSuccess(user: result.user, isNewUser: result.isNewUser))
            return result
        } catch {
            logManager?.trackEvent(event: AuthManagerEvent.signInAppleFail(error: error))
            throw error
        }
    }

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        logManager?.trackEvent(event: AuthManagerEvent.signInEmailStart)

        do {
            let result = try await service.signInEmail(email: email, password: password)
            self.auth = result.user

            logManager?.trackEvent(event: AuthManagerEvent.signInEmailSuccess(user: result.user, isNewUser: result.isNewUser))
            return result
        } catch {
            logManager?.trackEvent(event: AuthManagerEvent.signInEmailFail(error: error))
            throw error
        }
    }

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        logManager?.trackEvent(event: AuthManagerEvent.createAccountEmailStart)

        do {
            let result = try await service.createAccountEmail(email: email, password: password)
            self.auth = result.user

            logManager?.trackEvent(event: AuthManagerEvent.createAccountEmailSuccess(user: result.user, isNewUser: result.isNewUser))
            return result
        } catch {
            logManager?.trackEvent(event: AuthManagerEvent.createAccountEmailFail(error: error))
            throw error
        }
    }

    func signOut() throws {
        let currentAuth = auth

        do {
            try service.signOut()
            auth = nil

            logManager?.trackEvent(event: AuthManagerEvent.signOutSuccess(user: currentAuth))
        } catch {
            logManager?.trackEvent(event: AuthManagerEvent.signOutFail(error: error))
            throw error
        }
    }

    func deleteAccount() async throws {
        let currentAuth = auth
        logManager?.trackEvent(event: AuthManagerEvent.deleteAccountStart(user: currentAuth))

        do {
            try await service.deleteAccount()
            auth = nil

            logManager?.trackEvent(event: AuthManagerEvent.deleteAccountSuccess)
        } catch {
            logManager?.trackEvent(event: AuthManagerEvent.deleteAccountFail(error: error))
            throw error
        }
    }
}
