//
//  UserManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/04/2026.
//

import Foundation
import SwiftUI
import Combine
import SwiftfulUtilities

@MainActor
@Observable
class UserManager {
    private let service: UserService
    private(set) var currentUser: UserModel?

    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }

    private func addCurrentUserListener(userId: String) {
        Task {
            do {
                for try await value in service.streamUser(userId: userId) {
                    self.currentUser = value
                    print("USER HAS SOMETHING CHAAAAAAAAAAAAANGED")
                }
            } catch {
                print(error)
            }
        }
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)

        try await service.saveUser(user)
        addCurrentUserListener(userId: auth.uid)
    }

    func markOnboardingAsCompleted(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await service.markOnboardingAsCompleted(userId: uid, profileColorHex: profileColorHex)
    }

    func signOut() {
        currentUser = nil
    }

    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await service.deleteUser(userId: uid)
        signOut()
    }

    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        
        return uid
    }
}
