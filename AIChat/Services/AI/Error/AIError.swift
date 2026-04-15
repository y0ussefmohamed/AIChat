//
//  AIError.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation

enum AIError: Error, LocalizedError {
    case noImageFound
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .noImageFound:
            return "The AI did not return any image data."
        case .invalidImageData:
            return "The data returned could not be converted to a UIImage."
        }
    }
}
