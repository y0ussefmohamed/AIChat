//
//  WelcomeInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import Foundation

@MainActor
protocol WelcomeInteractor {
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: WelcomeInteractor {}
