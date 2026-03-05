//
//  Avatar.swift
//  AIChat
//
//  Created by Youssef Mohamed on 06/03/2026.
//

import Foundation

struct Avatar {
    let avatarID: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
    let authorId: String?
    let dateCreated: Date?

    var characterDescription: String? {
        guard characterOption != nil, characterAction != nil, characterLocation != nil else { return nil }

        return "A \(String(describing: characterOption!.rawValue)) that is \(String(describing: characterAction!.rawValue)) in the \(String(describing: characterLocation!.rawValue))."
    }

    init(
        avatarID: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarID = avatarID
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
    }

    static var mock: Avatar {
        mocks[0]
    }

    static var mocks: [Avatar] {
        [
            Avatar(avatarID: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .smiling, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            Avatar(avatarID: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .forest, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            Avatar(avatarID: UUID().uuidString, name: "Gamma", characterOption: .cat, characterAction: .drinking, characterLocation: .meusem, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            Avatar(avatarID: UUID().uuidString, name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now)
        ]
    }
}

enum CharacterOption: String {
    case man, woman, alien, dog, cat

    static var `default`: Self { // characterOption ?? CharacterOption.default.rawValue
        return .man
    }
}

enum CharacterAction: String {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying

    static var `default`: Self {
        return .sitting
    }
}

enum CharacterLocation: String {
    case park, mall, meusem, city, desert, forest, space

    static var `default`: Self {
        return .desert
    }
}
