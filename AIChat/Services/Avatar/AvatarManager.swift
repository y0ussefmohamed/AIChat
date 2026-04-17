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
    private let remote: RemoteAvatarService
    private let local: LocalAvatarPersistence

    init(services: AvatarServicesContainer) {
        self.remote = services.remote
        self.local = services.local
    }

    func addRecentAvatar(_ avatar: Avatar) throws {
        try local.addRecentAvatar(avatar: avatar)
    }

    func getRecentAvatars() throws -> [Avatar] {
        try local.getRecentAvatars()
    }

    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        try await remote.createAvatar(avatar: avatar, image: image)
    }

    func getAvatar(id: String) async throws -> Avatar {
        try await remote.getAvatar(id: id)
    }

    func getFeaturedAvatars() async throws -> [Avatar] {
        try await remote.getFeaturedAvatars()
    }

    func getPopularAvatars() async throws -> [Avatar] {
        try await remote.getPopularAvatars()
    }

    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar] {
        try await remote.getAvatarsByCategory(category)
    }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] {
        try await remote.getCurrentUserAvatars(userId: userId)
    }
}
