//
//  LogService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import Foundation

protocol LogService {
    func identifyUser(userId: String, name: String?, email: String?)
    func addUserProperties(properties: [String: Any])
    func deleteUserProfile()

    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}

/// protocol for event parameters
protocol LoggableEvent {
    var type: LogType { get }
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

enum EventExample: LoggableEvent, CaseIterable {
    case alpha, beta

    var type: LogType {
        switch self {
        case .alpha:
            return .severe
        case .beta:
            return .warning
        }
    }

    var eventName: String {
        switch self {
        case .alpha:
            return "ALPHA EVENT"
        case .beta:
            return "BETA EVENT"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .alpha:
            ["keyALPHA": "valueALPHA"]
        case .beta:
            ["keyBETA": "valueBETA"]
        }
    }
}
