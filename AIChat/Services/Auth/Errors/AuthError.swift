//
//  AuthError.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/04/2026.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case userNotFound
    case notSignedIn
    case needsReauthentication(providers: [String])
    case unknown

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "The user was not found."
        case .notSignedIn:
            return "The user is not signed in."
        case .needsReauthentication(providers: let providers):
            return "The user is not authenticated. Re-authenticate with \(providers.joined(separator: " or "))."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
