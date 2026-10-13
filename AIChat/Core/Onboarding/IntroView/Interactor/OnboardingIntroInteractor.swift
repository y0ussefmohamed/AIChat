//
//  OnboardingIntroInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import Foundation

@MainActor
protocol OnboardingIntroInteractor {
    var activeTests: ActiveABTests { get }

    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: OnboardingIntroInteractor {}
