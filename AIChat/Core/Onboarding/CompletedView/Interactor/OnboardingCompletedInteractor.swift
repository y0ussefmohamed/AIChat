//
//  OnboardingCompletedInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import Foundation

@MainActor
protocol OnboardingCompletedInteractor {
    func markOnboardingAsCompleted(profileColorHex: String) async throws
    func trackEvent(event: any LoggableEvent)
    func updateAppState(showTabBar: Bool)
}
extension CoreInteractor: OnboardingCompletedInteractor {}
