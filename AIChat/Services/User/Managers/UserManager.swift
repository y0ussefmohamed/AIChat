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
    private let remote: RemoteUserService
    private let local: LocalUserPersistence
    private(set) var currentUser: UserModel?

    init(services: UserServices) {
        self.remote = services.remote
        self.local = services.local

        self.currentUser = local.getCurrentUser()
    }

    private func addCurrentUserListener(userId: String) {
        Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value
                    self.saveCurrentUserInfoLocally()
                }
            } catch {
                print(error)
            }
        }
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)

        try await remote.saveUser(user)
        addCurrentUserListener(userId: auth.uid)
    }

    private func saveCurrentUserInfoLocally() {
        Task {
            do {
                try local.saveCurrentUser(currentUser)
                print("SUCCESS: Saved current user info locally")
            } catch {
                print("Error to save current user info locally: \(error)")
            }
        }
    }

    func markOnboardingAsCompleted(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.markOnboardingAsCompleted(userId: uid, profileColorHex: profileColorHex)
    }

    func signOut() {
        currentUser = nil
    }

    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        signOut()
    }

    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        
        return uid
    }
}
