//
//  AppViewModel.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import SwiftUI
import SwiftfulUtilities

@MainActor
@Observable
class AppViewModel {
    private let interactor: AppInteractor
    private var isCheckingUserStatus = false

    init(interactor: AppInteractor) {
        self.interactor = interactor
    }

    func showATTPromptIfNeeded() async {
        #if !DEBUG
        do {
            try await Task.sleep(for: .seconds(2))
        } catch {
            return
        }

        guard !Task.isCancelled else { return }
        let status = await AppTrackingTransparencyHelper.requestTrackingAuthorization()
        guard !Task.isCancelled else { return }
        interactor.trackEvent(event: AppViewEvent.attStatus(params: status.eventParameters))
        #endif
    }

    func checkUserStatus() async {
        guard !isCheckingUserStatus, !Task.isCancelled else { return }
        isCheckingUserStatus = true
        defer { isCheckingUserStatus = false }

        while !Task.isCancelled {
            if let user = interactor.auth {
                interactor.trackEvent(event: AppViewEvent.existingAuthStart)
                do {
                    try await interactor.logIn(auth: user, isNewUser: false)
                    try Task.checkCancellation()
                    interactor.trackEvent(event: AppViewEvent.existingAuthSuccess)
                    return
                } catch {
                    guard !(error is CancellationError), !Task.isCancelled else { return }
                    interactor.trackEvent(event: AppViewEvent.existingAuthFail(error: error))
                }
            } else {
                interactor.trackEvent(event: AppViewEvent.anonymousAuthStart)
                do {
                    let result = try await interactor.signInAnonymously()
                    try Task.checkCancellation()
                    try await interactor.logIn(auth: result.user, isNewUser: result.isNewUser)
                    try Task.checkCancellation()
                    interactor.trackEvent(event: AppViewEvent.anonymousAuthSuccess)
                    return
                } catch {
                    guard !(error is CancellationError), !Task.isCancelled else { return }
                    interactor.trackEvent(event: AppViewEvent.anonymousAuthFail(error: error))
                }
            }

            do {
                try await Task.sleep(for: .seconds(2.5))
            } catch {
                return
            }
        }
    }
}

extension AppViewModel {
    enum AppViewEvent: LoggableEvent {
        case attStatus(params: [String: Any])
        case existingAuthStart, existingAuthSuccess, existingAuthFail(error: Error)
        case anonymousAuthStart, anonymousAuthSuccess, anonymousAuthFail(error: Error)

        var eventName: String {
            switch self {
            case .attStatus:
                return "AppView_AttStatus"
            case .existingAuthStart:
                return "AppView_ExistingAuth_Start"
            case .existingAuthSuccess:
                return "AppView_ExistingAuth_Success"
            case .existingAuthFail:
                return "AppView_ExistingAuth_Fail"
            case .anonymousAuthStart:
                return "AppView_AnonymousAuth_Start"
            case .anonymousAuthSuccess:
                return "AppView_AnonymousAuth_Success"
            case .anonymousAuthFail:
                return "AppView_AnonymousAuth_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .attStatus(params: let params):
                return params
            case .existingAuthFail(error: let error):
                return error.asEventParameter
            case .anonymousAuthFail(error: let error):
                return error.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .existingAuthFail, .anonymousAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}
