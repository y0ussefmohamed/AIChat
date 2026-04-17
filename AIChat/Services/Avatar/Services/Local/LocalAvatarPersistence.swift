//
//  LocalAvatarPersistence.swift
//  AIChat
//
//  Created by Youssef Mohamed on 17/04/2026.
//

import Foundation
import SwiftData

@MainActor
protocol LocalAvatarPersistence {
    func addRecentAvatar(avatar: Avatar) throws
    func getRecentAvatars() throws -> [Avatar]
}
