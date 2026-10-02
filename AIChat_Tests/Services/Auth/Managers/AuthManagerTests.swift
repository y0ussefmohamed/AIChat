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
        let service = RecordingAuthService(user: expectedUser)
        let manager = AuthManager(service: service)

        #expect(manager.auth == expectedUser)
    }

    @Test("Initializing AuthManager with an unauthenticated service leaves auth nil")
    func init_withoutAuthenticatedUser_leavesAuthNil() {
        let service = RecordingAuthService(user: nil)
        let manager = AuthManager(service: service)

        #expect(manager.auth == nil)
    }

    @Test("getAuthId returns user UID when signed in and throws notSignedIn when signed out")
    func getAuthId_returnsUidOrThrowsNotSignedIn() throws {
        let user = UserAuthInfo.mock()
        let managerWithUser = AuthManager(service: RecordingAuthService(user: user))
        #expect(try managerWithUser.getAuthId() == user.uid)

        let managerWithoutUser = AuthManager(service: RecordingAuthService(user: nil))
        #expect(throws: AuthError.notSignedIn) {
            try managerWithoutUser.getAuthId()
        }
    }

    @Test("signInAnonymously updates auth state and returns new user result")
    func signInAnonymously_updatesAuthAndReturnsResult() async throws {
        let service = RecordingAuthService(user: nil)
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
        let service = RecordingAuthService(user: nil)
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
        let service = RecordingAuthService(user: nil)
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
        let service = RecordingAuthService(user: user)
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
        let service = RecordingAuthService(user: user)
        let manager = AuthManager(service: service)

        try await manager.deleteAccount()
        #expect(manager.auth == nil)
    }

    @Test("deleteAccount automatically re-authenticates with Apple when requested before deleting")
    func deleteAccount_withAppleReauthentication_reauthenticatesAndDeletes() async throws {
        let user = UserAuthInfo.mock()
        let service = RecordingAuthService(user: user)
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
        let service = RecordingAuthService(user: user)
        let manager = AuthManager(service: service)

        service.deleteAccountErrors = [AuthError.needsReauthentication(providers: ["password"])]

        await #expect(throws: AuthError.needsReauthentication(providers: ["password"])) {
            try await manager.deleteAccount()
        }
        #expect(manager.auth == user)
    }

    @Test("Every authentication operation propagates errors, preserves state, and logs the failure", arguments: ["anonymous", "apple", "email", "create_email"])
    func authenticationFailures_preserveStateAndLogError(operation: String) async {
        let user = UserAuthInfo(uid: "existing_user", email: "existing@example.com")
        let service = RecordingAuthService(user: user)
        service.signInAnonymouslyResult = .failure(ManagerTestError.requested)
        service.signInAppleResult = .failure(ManagerTestError.requested)
        service.signInEmailResult = .failure(ManagerTestError.requested)
        service.createAccountEmailResult = .failure(ManagerTestError.requested)
        let log = RecordingLogService()
        let manager = AuthManager(service: service, logManager: LogManager(services: [log]))
        let expectedPrefix: String
        switch operation {
        case "anonymous": expectedPrefix = "AuthManager_SignInAnonymous"
        case "apple": expectedPrefix = "AuthManager_SignInApple"
        case "email": expectedPrefix = "AuthManager_SignInEmail"
        default: expectedPrefix = "AuthManager_CreateAccountEmail"
        }

        await #expect(throws: ManagerTestError.requested) {
            switch operation {
            case "anonymous": _ = try await manager.signInAnonymously()
            case "apple": _ = try await manager.signInApple()
            case "email": _ = try await manager.signInEmail(email: "user@example.com", password: "password_123")
            default: _ = try await manager.createAccountEmail(email: "user@example.com", password: "password_123")
            }
        }
        #expect(manager.auth == user)
        #expect(log.events.map(\.name) == ["\(expectedPrefix)_Start", "\(expectedPrefix)_Fail"])
        #expect(log.events.last?.type == .warning)
    }

    @Test("Email authentication forwards exact email and password values", arguments: [false, true])
    func emailAuthentication_forwardsCredentials(isCreatingAccount: Bool) async throws {
        let service = RecordingAuthService(user: nil)
        let user = UserAuthInfo(uid: "email_user", email: "user@example.com")
        service.signInEmailResult = .success((user, false))
        service.createAccountEmailResult = .success((user, true))
        let manager = AuthManager(service: service)

        if isCreatingAccount {
            _ = try await manager.createAccountEmail(email: "user@example.com", password: "p@ss word 👋")
            #expect(service.authenticationCalls == ["create_email"])
        } else {
            _ = try await manager.signInEmail(email: "user@example.com", password: "p@ss word 👋")
            #expect(service.authenticationCalls == ["email"])
        }
        #expect(service.lastEmail == "user@example.com")
        #expect(service.lastPassword == "p@ss word 👋")
        #expect(manager.auth == user)
    }

    @Test("Authentication success logs the returned user and new-user flag", arguments: ["anonymous", "apple", "email", "create_email"])
    func authenticationSuccess_logsReturnedUser(operation: String) async throws {
        let service = RecordingAuthService(user: nil)
        let user = UserAuthInfo(uid: "signed_in_user", email: "signedin@example.com")
        service.signInAnonymouslyResult = .success((user, true))
        service.signInAppleResult = .success((user, true))
        service.signInEmailResult = .success((user, true))
        service.createAccountEmailResult = .success((user, true))
        let log = RecordingLogService()
        let manager = AuthManager(service: service, logManager: LogManager(services: [log]))
        let prefix: String

        switch operation {
        case "anonymous":
            _ = try await manager.signInAnonymously()
            prefix = "AuthManager_SignInAnonymous"
        case "apple":
            _ = try await manager.signInApple()
            prefix = "AuthManager_SignInApple"
        case "email":
            _ = try await manager.signInEmail(email: "signedin@example.com", password: "password")
            prefix = "AuthManager_SignInEmail"
        default:
            _ = try await manager.createAccountEmail(email: "signedin@example.com", password: "password")
            prefix = "AuthManager_CreateAccountEmail"
        }

        #expect(manager.auth == user)
        #expect(log.events.map(\.name) == ["\(prefix)_Start", "\(prefix)_Success"])
        #expect(log.events.last?.parameters?["uauth_uid"] as? String == "signed_in_user")
        #expect(log.events.last?.parameters?["is_new_user"] as? Bool == true)
        #expect(log.events.last?.type == .analytic)
    }

    @Test("Authentication listener updates state and identifies the stable UID")
    func authListener_updatesStateAndIdentity() async throws {
        let user = UserAuthInfo(uid: "firebase_uid", email: "user@example.com")
        let service = RecordingAuthService(user: nil)
        service.listenerValues = [user]
        let log = RecordingLogService()
        let manager = AuthManager(service: service, logManager: LogManager(services: [log]))

        let identified = await waitForManagerCondition { log.identities.count == 1 }

        #expect(identified)
        #expect(manager.auth == user)
        let identity = try #require(log.identities.first)
        #expect(identity.userId == "firebase_uid")
        #expect(identity.email == "user@example.com")
        #expect(identity.name == nil)
        #expect(log.userProperties.count == 2)
        #expect(log.userProperties.first?.properties["uauth_uid"] as? String == "firebase_uid")
    }

    @Test("A nil authentication listener update clears auth without identifying another user")
    func authListener_withNilValue_clearsState() async {
        let service = RecordingAuthService(user: UserAuthInfo(uid: "existing_user"))
        service.listenerValues = [nil]
        let log = RecordingLogService()
        let manager = AuthManager(service: service, logManager: LogManager(services: [log]))

        let cleared = await waitForManagerCondition { manager.auth == nil }

        #expect(cleared)
        #expect(log.identities.isEmpty)
        #expect(log.userProperties.isEmpty)
    }

    @Test("Sign-in replaces the registered listener after both success and failure", arguments: [false, true])
    func signIn_replacesExistingListener(shouldFail: Bool) async {
        let user = UserAuthInfo(uid: "user_123")
        let service = RecordingAuthService(user: user)
        service.signInAppleResult = shouldFail ? .failure(ManagerTestError.requested) : .success((user, false))
        let manager = AuthManager(service: service)
        let registered = await waitForManagerCondition { service.listenerCallCount == 1 }
        #expect(registered)

        if shouldFail {
            await #expect(throws: ManagerTestError.requested) { try await manager.signInApple() }
        } else {
            do {
                _ = try await manager.signInApple()
            } catch {
                Issue.record("Unexpected sign-in error: \(error)")
            }
        }
        let replaced = await waitForManagerCondition { service.listenerCallCount == 2 }

        #expect(replaced)
        #expect(service.removedListenerCount == 1)
    }

    @Test("Sign-out logging preserves the identity of the previous user")
    func signOut_logsPreviousUser() throws {
        let log = RecordingLogService()
        let service = RecordingAuthService(user: UserAuthInfo(uid: "user_123"))
        let manager = AuthManager(service: service, logManager: LogManager(services: [log]))

        try manager.signOut()

        #expect(manager.auth == nil)
        #expect(service.signOutCallCount == 1)
        #expect(log.events.first?.name == "AuthManager_SignOut_Success")
        #expect(log.events.first?.parameters?["uauth_uid"] as? String == "user_123")
    }

    @Test("Sign-out errors propagate and are logged without clearing authentication")
    func signOut_whenServiceFails_logsError() {
        let user = UserAuthInfo(uid: "user_123")
        let service = RecordingAuthService(user: user)
        service.signOutError = ManagerTestError.requested
        let log = RecordingLogService()
        let manager = AuthManager(service: service, logManager: LogManager(services: [log]))

        #expect(throws: ManagerTestError.requested) { try manager.signOut() }
        #expect(manager.auth == user)
        #expect(log.events.first?.name == "AuthManager_SignOut_Fail")
        #expect(log.events.first?.type == .warning)
    }

    @Test("Successful deletion logs start and success and clears auth")
    func deleteAccount_logsSuccessAndClearsState() async throws {
        let service = RecordingAuthService(user: UserAuthInfo(uid: "user_123"))
        let log = RecordingLogService()
        let manager = AuthManager(service: service, logManager: LogManager(services: [log]))

        try await manager.deleteAccount()

        #expect(manager.auth == nil)
        #expect(service.deleteAccountCallCount == 1)
        #expect(log.events.map(\.name) == ["AuthManager_DeleteAccount_Start", "AuthManager_DeleteAccount_Success"])
    }

    @Test("Apple reauthentication is followed by a second deletion attempt")
    func deleteAccount_withAppleReauthentication_retriesInOrder() async throws {
        let user = UserAuthInfo(uid: "user_123")
        let service = RecordingAuthService(user: user)
        service.deleteAccountErrors = [AuthError.needsReauthentication(providers: ["apple.com"])]
        service.signInAppleResult = .success((user, false))
        let manager = AuthManager(service: service)

        try await manager.deleteAccount()

        #expect(service.authenticationCalls == ["delete", "apple", "delete"])
        #expect(service.deleteAccountCallCount == 2)
        #expect(manager.auth == nil)
    }

    @Test("A failed Apple reauthentication stops deletion and preserves auth")
    func deleteAccount_whenAppleReauthenticationFails_stopsRetry() async {
        let user = UserAuthInfo(uid: "user_123")
        let service = RecordingAuthService(user: user)
        service.deleteAccountErrors = [AuthError.needsReauthentication(providers: ["apple.com"])]
        service.signInAppleResult = .failure(ManagerTestError.requested)
        let manager = AuthManager(service: service)

        await #expect(throws: ManagerTestError.requested) { try await manager.deleteAccount() }
        #expect(service.authenticationCalls == ["delete", "apple"])
        #expect(service.deleteAccountCallCount == 1)
        #expect(manager.auth == user)
    }

    @Test("A failed deletion retry preserves the reauthenticated user and propagates the retry error")
    func deleteAccount_whenRetryFails_preservesReauthenticatedUser() async {
        let original = UserAuthInfo(uid: "user_123", email: "old@example.com")
        let refreshed = UserAuthInfo(uid: "user_123", email: "refreshed@example.com")
        let service = RecordingAuthService(user: original)
        service.deleteAccountErrors = [
            AuthError.needsReauthentication(providers: ["apple.com"]),
            ManagerTestError.requested
        ]
        service.signInAppleResult = .success((refreshed, false))
        let manager = AuthManager(service: service)

        await #expect(throws: ManagerTestError.requested) { try await manager.deleteAccount() }

        #expect(service.authenticationCalls == ["delete", "apple", "delete"])
        #expect(manager.auth == refreshed)
    }

    @Test("Email, password, and unsupported reauthentication providers are propagated", arguments: [["email"], ["password"], ["google.com"], []])
    func deleteAccount_withNonAppleProviders_propagatesError(providers: [String]) async {
        let user = UserAuthInfo(uid: "user_123")
        let service = RecordingAuthService(user: user)
        let error = AuthError.needsReauthentication(providers: providers)
        service.deleteAccountErrors = [error]
        let manager = AuthManager(service: service)

        await #expect(throws: error) { try await manager.deleteAccount() }
        #expect(service.authenticationCalls == ["delete"])
        #expect(manager.auth == user)
    }

    @Test("Both AuthError and other deletion errors propagate and preserve auth", arguments: [false, true])
    func deleteAccount_withUnrecoverableError_preservesState(isAuthError: Bool) async {
        let user = UserAuthInfo(uid: "user_123")
        let service = RecordingAuthService(user: user)
        service.deleteAccountErrors = [isAuthError ? AuthError.unknown : ManagerTestError.requested]
        let log = RecordingLogService()
        let manager = AuthManager(service: service, logManager: LogManager(services: [log]))

        if isAuthError {
            await #expect(throws: AuthError.unknown) { try await manager.deleteAccount() }
        } else {
            await #expect(throws: ManagerTestError.requested) { try await manager.deleteAccount() }
        }
        #expect(manager.auth == user)
        #expect(log.events.map(\.name) == ["AuthManager_DeleteAccount_Start", "AuthManager_DeleteAccount_Fail"])
        #expect(log.events.last?.type == .warning)
    }
}

@MainActor
private final class RecordingAuthService: AuthService {
    var currentUser: UserAuthInfo?
    var signInAnonymouslyResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?
    var signInAppleResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?
    var signInEmailResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?
    var createAccountEmailResult: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?
    var signOutError: Error?
    var deleteAccountErrors: [Error] = []
    var listenerValues: [UserAuthInfo?] = []
    var listenerCallCount = 0
    var removedListenerCount = 0
    var authenticationCalls: [String] = []
    var signOutCallCount = 0
    var deleteAccountCallCount = 0
    var lastEmail: String?
    var lastPassword: String?

    init(user: UserAuthInfo?) { currentUser = user }

    func getAuthenticatedUser() -> UserAuthInfo? { currentUser }

    func addAuthenticatedUserListener(action: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        listenerCallCount += 1
        action(NSObject())
        return AsyncStream { continuation in
            for value in listenerValues { continuation.yield(value) }
            continuation.finish()
        }
    }

    func removeAuthenticatedUserListener(_ listener: any NSObjectProtocol) {
        removedListenerCount += 1
    }

    private func authenticate(_ result: Result<(user: UserAuthInfo, isNewUser: Bool), Error>?, anonymous: Bool, newUser: Bool) throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let value = try result?.get() ?? (UserAuthInfo(uid: "default_user", isAnonymous: anonymous), newUser)
        currentUser = value.0
        return value
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        authenticationCalls.append("anonymous")
        return try authenticate(signInAnonymouslyResult, anonymous: true, newUser: true)
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        authenticationCalls.append("apple")
        return try authenticate(signInAppleResult, anonymous: false, newUser: false)
    }

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        authenticationCalls.append("email")
        lastEmail = email
        lastPassword = password
        return try authenticate(signInEmailResult, anonymous: false, newUser: false)
    }

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        authenticationCalls.append("create_email")
        lastEmail = email
        lastPassword = password
        return try authenticate(createAccountEmailResult, anonymous: false, newUser: true)
    }

    func signOut() throws {
        signOutCallCount += 1
        if let signOutError { throw signOutError }
        currentUser = nil
    }

    func deleteAccount() async throws {
        authenticationCalls.append("delete")
        deleteAccountCallCount += 1
        if !deleteAccountErrors.isEmpty { throw deleteAccountErrors.removeFirst() }
        currentUser = nil
    }
}
