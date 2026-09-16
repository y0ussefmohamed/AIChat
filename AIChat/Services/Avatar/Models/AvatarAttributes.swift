//
//  AvatarAttributes.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import Foundation

nonisolated enum CharacterOption: String, CaseIterable, Hashable, Codable, Sendable {
    case man, woman, alien, dog, cat

    static var `default`: Self { // characterOption ?? CharacterOption.default.rawValue
        return .man
    }

    var asEventParameter: [String: Any] {
        ["character_option": self.rawValue]
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

nonisolated enum CharacterAction: String, CaseIterable, Hashable, Codable, Sendable {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying

    static var `default`: Self {
        return .sitting
    }

    var asEventParameter: [String: Any] {
        ["character_action": self.rawValue]
    }
}

nonisolated enum CharacterLocation: String, CaseIterable, Hashable, Codable, Sendable {
    case park, mall, meusem, city, desert, forest, space

    static var `default`: Self {
        return .desert
    }

    var asEventParameter: [String: Any] {
        ["character_location": self.rawValue]
    }
}
