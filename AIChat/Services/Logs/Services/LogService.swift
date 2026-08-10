//
//  LogService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import Foundation

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(properties: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()

    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
