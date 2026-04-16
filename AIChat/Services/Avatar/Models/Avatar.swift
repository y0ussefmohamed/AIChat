//
//  Avatar.swift
//  AIChat
//
//  Created by Youssef Mohamed on 06/03/2026.
//

import Foundation

struct Avatar: Hashable, Codable {
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authorId: String?
    let dateCreated: Date?

    var characterDescription: String? {
        guard let characterOption = characterOption, let characterAction = characterAction, let characterLocation = characterLocation else { return nil }

        return "\(characterOption.prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the \( characterLocation.rawValue)."
    }

    mutating func updateProfileImage(withName name: String) {
        self.profileImageName = name
    }

    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
    }

    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authorId = "author_id"
        case dateCreated = "date_created"
    }

    static var mock: Avatar {
        mocks[0]
    }

    static var mocks: [Avatar] {
        [
            Avatar(avatarId: UUID().uuidString, name: "Alpha", characterOption: .alien, characterAction: .smiling, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            Avatar(avatarId: UUID().uuidString, name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .forest, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            Avatar(avatarId: UUID().uuidString, name: "Gamma", characterOption: .cat, characterAction: .drinking, characterLocation: .meusem, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now),
            Avatar(avatarId: UUID().uuidString, name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now)
        ]
    }
}
