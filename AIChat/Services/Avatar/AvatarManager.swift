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
}
