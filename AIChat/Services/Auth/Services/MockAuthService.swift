//
//  MockAuthService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/04/2026.
//

import Foundation

struct MockAuthService: AuthService {

    let currentUser: UserAuthInfo?

    init(user: UserAuthInfo? = nil) {
        self.currentUser = user
    }

    func getAuthenticatedUser() -> UserAuthInfo? {
        return currentUser
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        return (UserAuthInfo.mock(isAnonymous: true), true)
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        return (UserAuthInfo.mock(isAnonymous: false), false)
    }

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        return (UserAuthInfo.mock(isAnonymous: false), false)
    }

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        return (UserAuthInfo.mock(isAnonymous: false), true)
    }

    func signOut() throws {

    }

    func deleteAccount() async throws {

    }
}
