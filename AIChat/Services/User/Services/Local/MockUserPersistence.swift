//
//  MockUserPersistence.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation

struct MockUserPersistence: LocalUserPersistence {
    let currentUser: UserModel?

    init(currentUser: UserModel? = nil) {
        self.currentUser = currentUser
    }

    func getCurrentUser() -> UserModel? {
        currentUser
    }
    
    func saveCurrentUser(_ user: UserModel?) throws { }
}
