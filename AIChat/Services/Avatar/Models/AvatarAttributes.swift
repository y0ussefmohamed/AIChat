//
//  AvatarAttributes.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import Foundation

enum CharacterOption: String, CaseIterable, Hashable, Codable {
    case man, woman, alien, dog, cat

    static var `default`: Self { // characterOption ?? CharacterOption.default.rawValue
        return .man
    }

    var pluralRawValue: String {
        switch self {
        case .man:
            return "men"
        case .woman:
            return "women"
        default:
            return "\(self.rawValue)s"
        }
    }

    var prefix: String {
        switch self {
        case .alien:
            return "An"
        default:
            return "A"
        }
    }
}

enum CharacterAction: String, CaseIterable, Hashable, Codable {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying

    static var `default`: Self {
        return .sitting
    }
}

enum CharacterLocation: String, CaseIterable, Hashable, Codable {
    case park, mall, meusem, city, desert, forest, space

    static var `default`: Self {
        return .desert
    }
}
