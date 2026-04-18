//
//  RemoteAvatarService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 16/04/2026.
//

import Foundation
import SwiftUI

protocol RemoteAvatarService {
    func createAvatar(avatar: Avatar, image: UIImage) async throws
    func getAvatar(id: String) async throws -> Avatar
    func getFeaturedAvatars() async throws -> [Avatar]
    func getPopularAvatars() async throws -> [Avatar]
    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar]
    func getCurrentUserAvatars(userId: String) async throws -> [Avatar]
    func incrementAvatarClickCount(avatarId: String) async throws
}
