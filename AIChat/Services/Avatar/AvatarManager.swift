//
//  AvatarManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

import Foundation
import SwiftUI
import Combine


@MainActor
@Observable
class AvatarManager {
    private let service: AvatarService

    init(service: AvatarService) {
        self.service = service
    }

    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        try await service.createAvatar(avatar: avatar, image: image)
    }

    func getFeaturedAvatars() async throws -> [Avatar] {
        try await service.getFeaturedAvatars()
    }

    func getPopularAvatars() async throws -> [Avatar] {
        try await service.getPopularAvatars()
    }

    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar] {
        try await service.getAvatarsByCategory(category)
    }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] {
        try await service.getCurrentUserAvatars(userId: userId)
    }
}
