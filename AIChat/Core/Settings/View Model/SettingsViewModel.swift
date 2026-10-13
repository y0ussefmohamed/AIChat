//
//  SettingsViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class SettingsViewModel {
    private let interactor: SettingsInteractor

    private(set) var isPremium = true

    var showCreateAccountView = false
    var showDeleteAccountConfirmation = false
    var showRatingModal = false

    var showAlert: AnyAppAlert?

    var currentUser: UserModel? { interactor.currentUser }
    var isAnonymousUser: Bool { interactor.auth?.isAnonymous ?? false }
    var hasUserAccount: Bool { interactor.auth != nil }
    var premiumStatus: String { isPremium ? "Premium" : "Free" }

    init(interactor: SettingsInteractor) {
        self.interactor = interactor
    }

    func onSignOutPressed(onDismiss: @escaping () async -> Void) {
        interactor.trackEvent(event: SettingsViewEvent.signOutStart)
        Task {
            do {
                try interactor.signOut()
                interactor.trackEvent(event: SettingsViewEvent.signOutSuccess)
                await onDismiss()
            } catch {
                interactor.trackEvent(event: SettingsViewEvent.signOutFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }

    func onRatingButtonPressed() {
        interactor.trackEvent(event: SettingsViewEvent.ratingPressed)
        AppStoreRatingsHelper.requestRatingsReview()
        showRatingModal = false
    }

    func onCreateAccountPressed() {
        interactor.trackEvent(event: SettingsViewEvent.createAccountPressed)
        showCreateAccountView = true
    }

    func onManagePurchasesPressed() {
        interactor.trackEvent(event: SettingsViewEvent.managePurchasesPressed)
    }

    func onContactUsPressed() {
        interactor.trackEvent(event: SettingsViewEvent.contactUsPressed)

        let email = "youssef.mo.ib@gmail.com"
        let emailString = "mailto:\(email)"

        guard let url = URL(string: emailString), UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url)

    }

    func onDeleteAccountPressed() {
        interactor.trackEvent(event: SettingsViewEvent.deleteAccountPressed)
        showDeleteAccountConfirmation = true
    }

    func onDeleteAccountConfirmed(onDismiss: @escaping () async -> Void) {
        interactor.trackEvent(event: SettingsViewEvent.deleteAccountStart)
        Task {
            do {
                let uid = try interactor.getAuthId()

                try await interactor.deleteUserAccount(userId: uid)
                interactor.deleteUserProfile()

                interactor.trackEvent(event: SettingsViewEvent.deleteAccountSuccess)
                await onDismiss()
            } catch {
                interactor.trackEvent(event: SettingsViewEvent.deleteAccountFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

extension SettingsViewModel {
    enum SettingsViewEvent: LoggableEvent {
        case signOutStart, signOutSuccess, signOutFail(error: Error)
        case createAccountPressed
        case deleteAccountPressed
        case deleteAccountStart, deleteAccountSuccess, deleteAccountFail(error: Error)
        case managePurchasesPressed
        case contactUsPressed
        case ratingPressed

        var eventName: String {
            switch self {
            case .signOutStart:
                return "SettingsView_SignOut_Start"
            case .signOutSuccess:
                return "SettingsView_SignOut_Success"
            case .signOutFail:
                return "SettingsView_SignOut_Fail"
            case .createAccountPressed:
                return "SettingsView_CreateAccount_Pressed"
            case .deleteAccountPressed:
                return "SettingsView_DeleteAccount_Pressed"
            case .deleteAccountStart:
                return "SettingsView_DeleteAccount_Start"
            case .deleteAccountSuccess:
                return "SettingsView_DeleteAccount_Success"
            case .deleteAccountFail:
                return "SettingsView_DeleteAccount_Fail"
            case .managePurchasesPressed:
                return "SettingsView_ManagePurchases_Pressed"
            case .contactUsPressed:
                return "SettingsView_ContactUs_Pressed"
            case .ratingPressed:
                return "SettingsView_Rating_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .signOutFail(error: let error),
                 .deleteAccountFail(error: let error):
                return error.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .deleteAccountFail, .signOutFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
