//
//  MockAuthService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/04/2026.
//

import Foundation

final class MockAuthService: AuthService, @unchecked Sendable {

    var currentUser: UserAuthInfo?
    var signInAnonymouslyResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?
    var signInAppleResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?
    var signInEmailResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?
    var createAccountEmailResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?
    var signOutError: Error?
    var deleteAccountErrors: [Error] = []

    init(
        user: UserAuthInfo? = nil,
        signInAnonymouslyResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>? = nil,
        signInAppleResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>? = nil,
        signInEmailResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>? = nil,
        createAccountEmailResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>? = nil,
        signOutError: Error? = nil,
        deleteAccountErrors: [Error] = []
    ) {
        self.currentUser = user
        self.signInAnonymouslyResult = signInAnonymouslyResult
        self.signInAppleResult = signInAppleResult
        self.signInEmailResult = signInEmailResult
        self.createAccountEmailResult = createAccountEmailResult
        self.signOutError = signOutError
        self.deleteAccountErrors = deleteAccountErrors
    }

    func addAuthenticatedUserListener(action: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            continuation.yield(self.currentUser)
        }
    }

    func removeAuthenticatedUserListener(_ listener: any NSObjectProtocol) {
        self.currentUser.map { print("removeAuthenticatedUserListener: \($0)") }
    }

    func getAuthenticatedUser() -> UserAuthInfo? {
        return currentUser
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        if let signInAnonymouslyResult {
            return try signInAnonymouslyResult.get()
        }
        return (UserAuthInfo.mock(isAnonymous: true), true)
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        if let signInAppleResult {
            return try signInAppleResult.get()
        }
        return (UserAuthInfo.mock(isAnonymous: false), false)
    }

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        if let signInEmailResult {
            return try signInEmailResult.get()
        }
        return (UserAuthInfo.mock(isAnonymous: false), false)
    }

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        if let createAccountEmailResult {
            return try createAccountEmailResult.get()
        }
        return (UserAuthInfo.mock(isAnonymous: false), true)
    }

    func signOut() throws {
        if let signOutError {
            throw signOutError
        }
    }

    func deleteAccount() async throws {
        if !deleteAccountErrors.isEmpty {
            throw deleteAccountErrors.removeFirst()
        }
    }
}
