//
//  AppInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 03/03/2026.
//

import Foundation

@MainActor
protocol AppInteractor {
    var auth: UserAuthInfo? { get }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: AppInteractor {}
