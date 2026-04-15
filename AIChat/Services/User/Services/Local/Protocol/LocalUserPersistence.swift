//
//  LocalUserPersistence.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation

protocol LocalUserPersistence: Sendable {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(_ user: UserModel?) throws
}
