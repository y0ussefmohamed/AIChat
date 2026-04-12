//
//  AuthError.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/04/2026.
//

import Foundation

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
