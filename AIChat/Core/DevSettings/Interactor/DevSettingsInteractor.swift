//
//  DevSettingsInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import Foundation

@MainActor
protocol DevSettingsInteractor {
    var canOverrideTests: Bool { get }
    var auth: UserAuthInfo? { get }
    var currentUser: UserModel? { get }
    var activeTests: ActiveABTests { get }

    func override(updatedTests: ActiveABTests) throws
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: DevSettingsInteractor {}
