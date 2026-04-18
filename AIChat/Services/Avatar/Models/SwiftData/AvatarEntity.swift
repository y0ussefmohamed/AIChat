//
//  AvatarEntity.swift
//  AIChat
//
//  Created by Youssef Mohamed on 17/04/2026.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class AvatarEntity {
    @Attribute(.unique) var avatarId: String
    var name: String?
    var characterOption: CharacterOption?
    var characterAction: CharacterAction?
    var characterLocation: CharacterLocation?
    var profileImageName: String?
    var authorId: String?
    var dateCreated: Date?
    var dateAddedToRecents: Date
    var clickCount: Int?

    init(from model: Avatar) {
        self.avatarId = model.avatarId
        self.name = model.name
        self.characterOption = model.characterOption
        self.characterAction = model.characterAction
        self.characterLocation = model.characterLocation
        self.profileImageName = model.profileImageName
        self.authorId = model.authorId
        self.dateCreated = model.dateCreated
        self.dateAddedToRecents = .now
        self.clickCount = model.clickCount
    }

    @MainActor
    func toModel() -> Avatar {
        Avatar(
            avatarId: self.avatarId,
            name: self.name,
            characterOption: self.characterOption,
            characterAction: self.characterAction,
            characterLocation: self.characterLocation,
            profileImageName: self.profileImageName,
            authorId: self.authorId,
            dateCreated: self.dateCreated,
            clickCount: self.clickCount
        )
    }
}
