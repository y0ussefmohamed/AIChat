//
//  Avatar.swift
//  AIChat
//
//  Created by Youssef Mohamed on 06/03/2026.
//

import Foundation
import IdentifiableByString

struct Avatar: Hashable, Codable, StringIdentifiable {
    var id: String { avatarId }
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authorId: String?
    let dateCreated: Date?
    let clickCount: Int?

    var characterDescription: String? {
        guard let characterOption = characterOption, let characterAction = characterAction, let characterLocation = characterLocation else { return nil }

        return "\(characterOption.prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the \( characterLocation.rawValue)."
    }

    var asEventParameter: [String: Any] {
        let dict: [String: Any?] = [
            "avatar_\(CodingKeys.avatarId.rawValue)": avatarId,
            "avatar_\(CodingKeys.name.rawValue)": name,
            "avatar_\(CodingKeys.characterOption.rawValue)": characterOption?.asEventParameter,
            "avatar_\(CodingKeys.characterAction.rawValue)": characterAction?.asEventParameter,
            "avatar_\(CodingKeys.characterLocation.rawValue)": characterLocation?.asEventParameter,
            "avatar_\(CodingKeys.profileImageName.rawValue)": profileImageName,
            "avatar_\(CodingKeys.authorId.rawValue)": authorId,
            "avatar_\(CodingKeys.dateCreated.rawValue)": dateCreated,
            "avatar_\(CodingKeys.clickCount.rawValue)": clickCount
        ]

        return dict.compactMapValues({$0})
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
        dateCreated: Date? = nil,
        clickCount: Int? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
        self.clickCount = clickCount
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
        case clickCount = "click_count"
    }

    static func newAvatar(name: String, option: CharacterOption, action: CharacterAction, location: CharacterLocation, authorId: String) -> Self {
        .init(
            avatarId: UUID().uuidString,
            name: name,
            characterOption: option,
            characterAction: action,
            characterLocation: location,
            profileImageName: nil,
            authorId: authorId,
            dateCreated: .now,
            clickCount: 0
        )
    }

    static var mock: Avatar {
        mocks[0]
    }

    static var mocks: [Avatar] {
        [
            Avatar(avatarId: "av1", name: "Alpha", characterOption: .alien, characterAction: .smiling, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 10),
            Avatar(avatarId: "av2", name: "Beta", characterOption: .dog, characterAction: .eating, characterLocation: .forest, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 5),
            Avatar(avatarId: "av3", name: "Gamma", characterOption: .cat, characterAction: .drinking, characterLocation: .meusem, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 100),
            Avatar(avatarId: "av4", name: "Delta", characterOption: .woman, characterAction: .shopping, characterLocation: .park, profileImageName: Constants.randomImage, authorId: UUID().uuidString, dateCreated: .now, clickCount: 0)
        ]
    }
}
