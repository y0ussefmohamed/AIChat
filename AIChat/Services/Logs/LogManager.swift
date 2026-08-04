//
//  LogManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class LogManager {
    private let services: [LogService]

    init(services: [LogService]) {
        self.services = services
    }

    func identifyUser(userId: String, name: String?, email: String?) {
        services.forEach {
            $0.identifyUser(userId: userId, name: name, email: email)
        }
    }

    func addUserProperties(properties: [String: Any]) {
        services.forEach {
            $0.addUserProperties(properties: properties)
        }
    }

    func deleteUserProfile() {
        services.forEach {
            $0.deleteUserProfile()
        }
    }

    func trackEvent(event: any LoggableEvent) {
        services.forEach {
            $0.trackEvent(event: event)
        }
    }

    func trackScreenEvent(event: any LoggableEvent) {
        services.forEach {
            $0.trackScreenEvent(event: event)
        }
    }
}
