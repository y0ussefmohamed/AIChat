//
//  MockAvatarService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

import Foundation
import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        
    }

    func getAvatar(id: String) async throws -> Avatar {
        .mock
    }

    func getFeaturedAvatars() async throws -> [Avatar] {
        Avatar.mocks.shuffled()
    }

    func getPopularAvatars() async throws -> [Avatar] {
        Avatar.mocks.shuffled()
    }

    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar] {
        Avatar.mocks.shuffled()
    }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] {
        Avatar.mocks.shuffled()
    }
}
