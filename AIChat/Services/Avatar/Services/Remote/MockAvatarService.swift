//
//  MockAvatarService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

import Foundation
import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    let avatars: [Avatar]
    let delay: Double

    init(avatars: [Avatar] = Avatar.mocks, delay: Double = 1) {
        self.avatars = avatars
        self.delay = delay
    }

    func createAvatar(avatar: Avatar, image: UIImage) async throws { }

    func getAvatar(id: String) async throws -> Avatar {
        guard let avatar = avatars.first(where: {$0.id == id}) else {
            throw URLError(.badServerResponse)
        }

        return avatar
    }

    func getFeaturedAvatars() async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(delay))
        return avatars.shuffled()
    }

    func getPopularAvatars() async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(delay))
        return avatars.shuffled()
    }

    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(delay))
        return avatars.shuffled()
    }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] {
        try await Task.sleep(for: .seconds(delay))
        return avatars.shuffled()
    }

    func incrementAvatarClickCount(avatarId: String) async throws { }
}
