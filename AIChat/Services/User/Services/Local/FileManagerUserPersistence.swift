//
//  FileManagerUserPersistence.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation

struct FileManagerUserPersistence: LocalUserPersistence {
    private let userDocumentKey: String = "current_user"

    func getCurrentUser() -> UserModel? {
        try? FileManager.getDocument(key: userDocumentKey)
    }

    func saveCurrentUser(_ user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
