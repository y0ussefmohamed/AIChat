//
//  AuthService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/04/2026.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry /// to use `\.authService` as a `Keypath` in the `@Environment`
    var authServices: AuthService = MockAuthService()
    /// this class will be created at the start of the app and will always be in the `@Environment`
}

protocol AuthService: Sendable {
    func getAuthenticatedUser() -> UserAuthInfo?

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)

    func signOut() throws

    func deleteAccount() async throws
}
