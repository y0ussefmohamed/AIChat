//
//  CategoryListInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import Foundation

protocol CategoryListInteractor {
    func trackEvent(event: any LoggableEvent)
    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar]
}
extension CoreInteractor: CategoryListInteractor { }
