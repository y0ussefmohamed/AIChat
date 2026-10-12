//
//  ExploreInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/10/2026.
//

import Foundation

@MainActor
protocol ExploreInteractor {
    var auth: UserAuthInfo? { get }
    var activeTests: ActiveABTests { get }

    func isAuthorized() async -> Bool
    func schedulePushNotificationsForTheNextWeek() async throws
    func requestAuthorization() async throws -> Bool
    func canRequestAuthorization() async -> Bool
    func trackEvent(event: any LoggableEvent)
    func getFeaturedAvatars() async throws -> [Avatar]
    func getPopularAvatars() async throws -> [Avatar]
}
extension CoreInteractor: ExploreInteractor { }
