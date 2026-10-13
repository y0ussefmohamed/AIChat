//
//  OnboardingColorInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import Foundation

@MainActor
protocol OnboardingColorInteractor {
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: OnboardingColorInteractor {}
