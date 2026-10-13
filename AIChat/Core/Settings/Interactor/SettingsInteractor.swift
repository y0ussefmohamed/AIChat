//
//  SettingsInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import Foundation

@MainActor
protocol SettingsInteractor {
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }

    func getAuthId() throws -> String
    func signOut() throws
    func deleteUserAccount(userId: String) async throws
    func deleteUserProfile()
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: SettingsInteractor {}
