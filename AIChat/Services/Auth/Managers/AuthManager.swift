//
//  AuthManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/04/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
@Observable /// `@Observable` class means we can have instance from this class in an environment scope we choose
class AuthManager {
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?

    init(service: AuthService) {
        self.service = service
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }

    private func addAuthListener() {
        Task {
            for await value in service.addAuthenticatedUserListener(action: { listner in
                self.listener = listner
            }) {
                self.auth = value
                print("Auth Listener Success \(value?.uid ?? "NO UID")")
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
        let result = try await service.signInAnonymously()
        self.auth = result.user
        return result
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await service.signInApple()
        self.auth = result.user
        return result
    }

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await service.signInEmail(email: email, password: password)
        self.auth = result.user
        return result
    }

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await service.createAccountEmail(email: email, password: password)
        self.auth = result.user
        return result
    }

    func signOut() throws {
        try service.signOut()
        auth = nil
    }

    func deleteAccount() async throws {
        try await service.deleteAccount()
        auth = nil
    }
}
