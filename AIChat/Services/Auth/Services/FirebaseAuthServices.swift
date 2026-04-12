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

enum EmailAuthError: Error, LocalizedError {
    case invalidEmail
    case wrongPassword
    case weakPassword
    case emailAlreadyInUse
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email, please enter a valid email"
        case .wrongPassword:
            return "Wrong Password"
        case .weakPassword:
            return "Weak Password, enter a password with more than 5 characters"
        case .emailAlreadyInUse:
            return "An account with this email already exists. Please sign in instead."
        case .unknown:
            return "Unknown Error!"
        }
    }
}

struct FirebaseAuthServices: AuthService {
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
                let mappedError = mapFirebaseAuthError(error)

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
            throw mapFirebaseAuthError(error)
        }
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


extension FirebaseAuthServices {
    private func mapFirebaseAuthError(_ error: Error) -> EmailAuthError {
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
}
