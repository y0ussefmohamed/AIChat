//
//  LinkProviderInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 11/03/2026.
//

import Foundation

@MainActor
protocol LinkProviderInteractor {
    var currentUser: UserModel? { get }

    func trackEvent(event: any LoggableEvent)
    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
}
extension CoreInteractor: LinkProviderInteractor { }
