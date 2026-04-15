//
//  RemoteUserService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation

protocol RemoteUserService: Sendable {
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>

    func saveUser(_ user: UserModel) async throws

    func markOnboardingAsCompleted(userId: String, profileColorHex: String) async throws

    func deleteUser(userId: String) async throws
}
