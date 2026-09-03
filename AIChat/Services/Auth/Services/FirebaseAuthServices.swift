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

struct FirebaseAuthServices: AuthService {
    /// listens for every change in the `Auth.auth().currentUser` Status
    func addAuthenticatedUserListener(action: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation.yield(user)
                } else {
                    continuation.yield(nil)
                }
            }

            action(listener)
        }
    }

    func removeAuthenticatedUserListener(_ listener: any NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(listener)
    }

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

        if let user = Auth.auth().currentUser, user.isAnonymous, let result = try? await user.link(with: credential) {
            return result.asAuthInfo
        }

        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            } catch {
                let mappedError = mapSignInAuthError(error)

                if mappedError == .emailAlreadyInUse {
                    try? await user.delete()

                    let result = try await Auth.auth().signIn(with: credential)
                    return result.asAuthInfo

                } else {
                    throw mappedError
                }
            }
        }

        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        do {
            if let user = Auth.auth().currentUser, user.isAnonymous {
                let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            } else {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                return result.asAuthInfo
            }
        } catch {
            throw mapCreateAuthError(error)
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.userNotFound }

        do {
            try await user.delete()
        } catch let error as NSError {
            let authError = AuthErrorCode(rawValue: error.code)

            switch authError {
            case .requiresRecentLogin:
                throw AuthError.needsReauthentication(providers: user.providerData.compactMap(\.providerID))
            default:
                throw error
            }
        }
    }
}

extension AuthDataResult {
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: self.user)
        let isNewUser = self.additionalUserInfo?.isNewUser ?? true

        return (user, isNewUser)
    }
}


extension FirebaseAuthServices {
    /// Maps generic Firebase errors to custom Create (Sign Up) errors
    func mapCreateAuthError(_ error: Error) -> CreateEmailAuthError {
        let nsError = error as NSError
        let authErrorCode = AuthErrorCode(rawValue: nsError.code)

        switch authErrorCode {
        case .emailAlreadyInUse, .credentialAlreadyInUse:
            return .emailAlreadyInUse
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        default:
            return .unknown
        }
    }

    /// Maps generic Firebase errors to custom Sign In errors
    func mapSignInAuthError(_ error: Error) -> SignInEmailAuthError {
        let nsError = error as NSError
        let authErrorCode = AuthErrorCode(rawValue: nsError.code)

        switch authErrorCode {
        case .invalidEmail, .userNotFound:
            return .invalidEmail
        case .wrongPassword:
            return .wrongPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        default:
            return .unknown
        }
    }
}
