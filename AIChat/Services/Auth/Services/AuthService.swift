//
//  AuthService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/04/2026.
//

import Foundation
import SwiftUI


protocol AuthService: Sendable {
    func addAuthenticatedUserListener(action: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?>

    func getAuthenticatedUser() -> UserAuthInfo?

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool)

    func signOut() throws

    func deleteAccount() async throws
}
