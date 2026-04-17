//
//  MockLocalAvatarPersistence.swift
//  AIChat
//
//  Created by Youssef Mohamed on 17/04/2026.
//

import Foundation

@MainActor
struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    func addRecentAvatar(avatar: Avatar) throws {}
    func getRecentAvatars() throws -> [Avatar] { Avatar.mocks.shuffled() }
}
