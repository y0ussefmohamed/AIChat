//
//  MockUserService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation

struct MockUserService: UserService {
    let currentUser: UserModel?

    init(user: UserModel?) {
        self.currentUser = user
    }

    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        return AsyncThrowingStream { _ in }
    }

    func saveUser(_ user: UserModel) async throws { }

    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws { }

    func deleteUser(userId: String) async throws  { }
}
