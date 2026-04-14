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
    case unknown

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "The user was not found."
        case .notSignedIn:
            return "The user is not signed in."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
