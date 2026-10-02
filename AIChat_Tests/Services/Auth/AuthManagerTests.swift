//
//  AuthManagerTests.swift
//  AIChat_Tests
//
//  Created by Youssef Mohamed on 02/10/2026.
//

import Foundation
import Testing
@testable import AIChat

@MainActor
struct AuthManagerTests {
    
    @Test("Initializing AuthManager with an authenticated user sets initial auth state")
    func init_withAuthenticatedUser_setsInitialAuth() {
        let expectedUser = UserAuthInfo.mock(isAnonymous: false)
        let service = MockAuthService(user: expectedUser)
        let manager = AuthManager(service: service)

        #expect(manager.auth == expectedUser)
    }

    @Test("Initializing AuthManager with an unauthenticated service leaves auth nil")
    func init_withoutAuthenticatedUser_leavesAuthNil() {
        let service = MockAuthService(user: nil)
        let manager = AuthManager(service: service)

        #expect(manager.auth == nil)
    }

    @Test("getAuthId returns user UID when signed in and throws notSignedIn when signed out")
    func getAuthId_returnsUidOrThrowsNotSignedIn() throws {
        let user = UserAuthInfo.mock()
        let managerWithUser = AuthManager(service: MockAuthService(user: user))
        #expect(try managerWithUser.getAuthId() == user.uid)

        let managerWithoutUser = AuthManager(service: MockAuthService(user: nil))
        #expect(throws: AuthError.notSignedIn) {
            try managerWithoutUser.getAuthId()
        }
    }

    @Test("signInAnonymously updates auth state and returns new user result")
    func signInAnonymously_updatesAuthAndReturnsResult() async throws {
        let service = MockAuthService(user: nil)
        let manager = AuthManager(service: service)

        let anonUser = UserAuthInfo(uid: "anon_uid_1", isAnonymous: true)
        service.signInAnonymouslyResult = .success((user: anonUser, isNewUser: true))

        let result = try await manager.signInAnonymously()

        #expect(result.user == anonUser)
        #expect(result.isNewUser == true)
        #expect(manager.auth == anonUser)
    }

    @Test("signInApple updates auth state and returns user result")
    func signInApple_updatesAuthAndReturnsResult() async throws {
        let service = MockAuthService(user: nil)
        let manager = AuthManager(service: service)

        let appleUser = UserAuthInfo(uid: "apple_uid_1", email: "apple@example.com", isAnonymous: false)
        service.signInAppleResult = .success((user: appleUser, isNewUser: false))

        let result = try await manager.signInApple()

        #expect(result.user == appleUser)
        #expect(result.isNewUser == false)
        #expect(manager.auth == appleUser)
    }

    @Test("signInEmail and createAccountEmail update auth state on success")
    func emailAuth_updatesAuthAndReturnsResult() async throws {
        let service = MockAuthService(user: nil)
        let manager = AuthManager(service: service)

        let emailUser = UserAuthInfo(uid: "email_uid_1", email: "email@example.com", isAnonymous: false)
        service.signInEmailResult = .success((user: emailUser, isNewUser: false))

        let signInResult = try await manager.signInEmail(email: "email@example.com", password: "password123")
        #expect(signInResult.user == emailUser)
        #expect(manager.auth == emailUser)

        let createdUser = UserAuthInfo(uid: "created_uid_1", email: "created@example.com", isAnonymous: false)
        service.createAccountEmailResult = .success((user: createdUser, isNewUser: true))

        let createResult = try await manager.createAccountEmail(email: "created@example.com", password: "password123")
        #expect(createResult.user == createdUser)
        #expect(manager.auth == createdUser)
    }

    @Test("signOut clears auth state on success and preserves auth when service throws")
    func signOut_clearsAuthOrPreservesOnError() throws {
        let user = UserAuthInfo.mock()
        let service = MockAuthService(user: user)
        let manager = AuthManager(service: service)

        // When signOut throws, auth is preserved
        service.signOutError = AuthError.unknown
        #expect(throws: AuthError.unknown) {
            try manager.signOut()
        }
        #expect(manager.auth == user)

        // When signOut succeeds, auth is cleared
        service.signOutError = nil
        try manager.signOut()
        #expect(manager.auth == nil)
    }

    @Test("deleteAccount clears auth state on success")
    func deleteAccount_clearsAuthOnSuccess() async throws {
        let user = UserAuthInfo.mock()
        let service = MockAuthService(user: user)
        let manager = AuthManager(service: service)

        try await manager.deleteAccount()
        #expect(manager.auth == nil)
    }

    @Test("deleteAccount automatically re-authenticates with Apple when requested before deleting")
    func deleteAccount_withAppleReauthentication_reauthenticatesAndDeletes() async throws {
        let user = UserAuthInfo.mock()
        let service = MockAuthService(user: user)
        let manager = AuthManager(service: service)

        // First attempt throws needsReauthentication with apple.com
        service.deleteAccountErrors = [AuthError.needsReauthentication(providers: ["apple.com"])]
        service.signInAppleResult = .success((user: user, isNewUser: false))

        try await manager.deleteAccount()
        #expect(manager.auth == nil)
    }

    @Test("deleteAccount propagates error when service throws a non-recoverable error")
    func deleteAccount_whenNonRecoverableError_propagatesError() async {
        let user = UserAuthInfo.mock()
        let service = MockAuthService(user: user)
        let manager = AuthManager(service: service)

        service.deleteAccountErrors = [AuthError.needsReauthentication(providers: ["password"])]

        await #expect(throws: AuthError.needsReauthentication(providers: ["password"])) {
            try await manager.deleteAccount()
        }
        #expect(manager.auth == user)
    }
}
