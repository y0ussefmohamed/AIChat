//
//  EmailAuthError.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/04/2026.
//

import Foundation

enum CreateEmailAuthError: Error, LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email, please enter a valid email"
        case .weakPassword:
            return "Weak Password, enter a password with more than 5 characters"
        case .emailAlreadyInUse:
            return "An account with this email already exists. Please sign in instead."
        case .unknown:
            return "Unknown Error!"
        }
    }
}

enum SignInEmailAuthError: Error, LocalizedError {
    case invalidEmail
    case wrongPassword
    case emailAlreadyInUse
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email, please enter a valid email"
        case .wrongPassword:
            return "Wrong Password"
        case .emailAlreadyInUse:
            return .none
        case .unknown:
            return "Unknown Error!"
        }
    }
}
