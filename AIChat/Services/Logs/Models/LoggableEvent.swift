//
//  for.swift
//  AIChat
//
//  Created by Youssef Mohamed on 08/08/2026.
//

import Foundation

/// protocol for event parameters
protocol LoggableEvent {
    var type: LogType { get }
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

// MARK: - NOW WE CAN USE THIS DIRECTLY WITHOUT MAKING AN ENUM
/// this is used to not make an enum that conforms to `LoggableEvent` each time you want to make an event... just create an object using this struct
struct AnyLoggableEvent: LoggableEvent {
    let type: LogType
    let eventName: String
    let parameters: [String: Any]?

    init(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        self.eventName = eventName
        self.parameters = parameters
        self.type = type
    }
}

// MARK: - BEFORE DOING THE STRUCT ABOVE
/// this has to be created before doing the struct
enum EventExample: LoggableEvent, CaseIterable {
    case alpha, beta, gamma

    var type: LogType {
        switch self {
        case .alpha:
            return .severe
        case .beta:
            return .warning
        case .gamma:
            return .analytic
        }
    }

    var eventName: String {
        switch self {
        case .alpha:
            return "ALPHA EVENT"
        case .beta:
            return "BETA EVENT"
        case .gamma:
            return "GAMMA EVENT"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .alpha:
            ["keyALPHA": "valueALPHA"]
        case .beta:
            ["keyBETA": "valueBETA"]
        case .gamma:
            ["keyGAMMA": "valueGAMMA"]
        }
    }
}
