//
//  FirebaseAuthServices.swift
//  AIChat
//
//  Created by Youssef Mohamed on 23/03/2026.
//

import Foundation
import FirebaseAuth
import SignInAppleAsync
import SwiftUI

enum AuthError: Error, LocalizedError {
    case unknown
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred."
        case .userNotFound:
            return "The user was not found."
        }
    }
}

extension EnvironmentValues {
    @Entry /// to use `\.authService` as a `Keypath` in the `@Environment`
    var authServices: FirebaseAuthServices = FirebaseAuthServices()
    /// this class will be created at the start of the app and will always be in the `@Environment`
}

struct FirebaseAuthServices {
    func getAuthenticatedUser() -> UserAuthInfo? {
        if let user = Auth.auth().currentUser {
            return UserAuthInfo(user: user)
        }

        return nil
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = SignInWithAppleHelper()
        let response = try await helper.signIn()
        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: response.token,
            rawNonce: response.nonce
        )

        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.userNotFound }
        try await user.delete()
    }
}

extension AuthDataResult {
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: self.user)
        let isNewUser = self.additionalUserInfo?.isNewUser ?? true

        return (user, isNewUser)
    }
}
