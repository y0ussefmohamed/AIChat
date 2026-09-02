//
//  UserManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/04/2026.
//

import Foundation
import SwiftUI
import Combine
import SwiftfulUtilities

@MainActor
@Observable
class UserManager {
    private let remote: RemoteUserService
    private let local: LocalUserPersistence
    private(set) var currentUser: UserModel?
    private let logManager: LogManager?

    init(services: UserServicesContainer, logManager: LogManager? = nil) {
        self.remote = services.remote
        self.local = services.local
        self.logManager = logManager

        self.currentUser = local.getCurrentUser()
    }

    enum UserManagerEvent: LoggableEvent {
        case logInStart(isNewUser: Bool), logInSuccess(user: UserModel?, isNewUser: Bool), logInFail(error: Error)
        case streamUserSuccess(user: UserModel?), streamUserFail(error: Error)
        case saveUserLocallyFail(error: Error)
        case markOnboardingStart(profileColorHex: String), markOnboardingSuccess(user: UserModel?), markOnboardingFail(error: Error)
        case signOut(user: UserModel?)
        case deleteUserStart(user: UserModel?), deleteUserSuccess, deleteUserFail(error: Error)

        var eventName: String {
            switch self {
            case .logInStart:
                return "UserManager_LogIn_Start"
            case .logInSuccess:
                return "UserManager_LogIn_Success"
            case .logInFail:
                return "UserManager_LogIn_Fail"
            case .streamUserSuccess:
                return "UserManager_StreamUser_Success"
            case .streamUserFail:
                return "UserManager_StreamUser_Fail"
            case .saveUserLocallyFail:
                return "UserManager_SaveUserLocally_Fail"
            case .markOnboardingStart:
                return "UserManager_MarkOnboarding_Start"
            case .markOnboardingSuccess:
                return "UserManager_MarkOnboarding_Success"
            case .markOnboardingFail:
                return "UserManager_MarkOnboarding_Fail"
            case .signOut:
                return "UserManager_SignOut"
            case .deleteUserStart:
                return "UserManager_DeleteUser_Start"
            case .deleteUserSuccess:
                return "UserManager_DeleteUser_Success"
            case .deleteUserFail:
                return "UserManager_DeleteUser_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .logInStart(isNewUser: let isNewUser):
                return isNewUser.asEventParameter(key: "is_new_user")

            case .logInSuccess(user: let user, isNewUser: let isNewUser):
                return (user?.asEventParameter ?? [:])
                    .merged(isNewUser.asEventParameter(key: "is_new_user"))

            case .markOnboardingStart(profileColorHex: let hexStr):
                return hexStr.asEventParameter(key: "profile_color_hex")

            case .markOnboardingSuccess(user: let user),
                    .streamUserSuccess(user: let user),
                    .signOut(user: let user),
                    .deleteUserStart(user: let user):
                return user?.asEventParameter

            case .logInFail(error: let error),
                 .streamUserFail(error: let error),
                 .saveUserLocallyFail(error: let error),
                 .markOnboardingFail(error: let error),
                 .deleteUserFail(error: let error):
                return error.asEventParameter

            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .streamUserFail, .saveUserLocallyFail, .logInFail:
                return .severe
            case .markOnboardingFail, .deleteUserFail:
                return .warning
            default:
                return .analytic
            }
        }
    }

    private func addCurrentUserListener(userId: String) {
        Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value

                    logManager?.trackEvent(event: UserManagerEvent.streamUserSuccess(user: value))
                    logManager?.addUserProperties(properties: value.asEventParameter, isHighPriority: true)
                    logManager?.addUserProperties(properties: Utilities.eventParameters, isHighPriority: false)

                    self.saveCurrentUserInfoLocally()
                }
            } catch {
                logManager?.trackEvent(event: UserManagerEvent.streamUserFail(error: error))
            }
        }
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        logManager?.trackEvent(event: UserManagerEvent.logInStart(isNewUser: isNewUser))

        do {
            let creationVersion = isNewUser ? Utilities.appVersion : nil
            let user = UserModel(auth: auth, creationVersion: creationVersion)

            try await remote.saveUser(user)
            addCurrentUserListener(userId: auth.uid) /// this changes `self.currentUser`

            logManager?.trackEvent(event: UserManagerEvent.logInSuccess(user: user, isNewUser: isNewUser))
        } catch {
            logManager?.trackEvent(event: UserManagerEvent.logInFail(error: error))
            throw error
        }
    }

    private func saveCurrentUserInfoLocally() {
        Task {
            do {
                try local.saveCurrentUser(currentUser)
            } catch {
                logManager?.trackEvent(event: UserManagerEvent.saveUserLocallyFail(error: error))
            }
        }
    }

    func markOnboardingAsCompleted(profileColorHex: String) async throws {
        logManager?.trackEvent(event: UserManagerEvent.markOnboardingStart(profileColorHex: profileColorHex))

        do {
            let uid = try currentUserId()
            try await remote.markOnboardingAsCompleted(userId: uid, profileColorHex: profileColorHex)

            logManager?.trackEvent(event: UserManagerEvent.markOnboardingSuccess(user: currentUser))
        } catch {
            logManager?.trackEvent(event: UserManagerEvent.markOnboardingFail(error: error))
            throw error
        }
    }

    func signOut() {
        logManager?.trackEvent(event: UserManagerEvent.signOut(user: currentUser))
        currentUser = nil
    }

    func deleteCurrentUser() async throws {
        logManager?.trackEvent(event: UserManagerEvent.deleteUserStart(user: currentUser))

        do {
            let uid = try currentUserId()
            try await remote.deleteUser(userId: uid)
            logManager?.trackEvent(event: UserManagerEvent.deleteUserSuccess)
            signOut()
        } catch {
            logManager?.trackEvent(event: UserManagerEvent.deleteUserFail(error: error))
            throw error
        }
    }

    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }

        return uid
    }
}
