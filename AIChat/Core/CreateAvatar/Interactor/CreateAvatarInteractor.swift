//
//  CreateAvatarInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

@MainActor
protocol CreateAvatarInteractor {
    func trackEvent(event: any LoggableEvent)
    func getAuthId() throws -> String
    func generateImage(input: String) async throws -> UIImage
    func createAvatar(avatar: Avatar, image: UIImage) async throws
}
extension CoreInteractor: CreateAvatarInteractor { }
