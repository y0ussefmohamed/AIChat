//
//  OnboardingCommunityInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

@MainActor
protocol OnboardingCommunityInteractor {
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: OnboardingCommunityInteractor {}
