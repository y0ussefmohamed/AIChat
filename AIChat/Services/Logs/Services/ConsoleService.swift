//
//  ConsoleService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import Foundation

struct ConsoleService: LogService {

    let logger = LogSystem()
    private let printParams: Bool

    init(printParams: Bool = true) {
        self.printParams = printParams

        logger.log(.info, "Info OS Logger Test")
        logger.log(.analytic, "Analytic OS Logger Test")
        logger.log(.warning, "Warning OS Logger Test")
        logger.log(.severe, "Severe OS Logger Test")
    }

    func identifyUser(
        userId: String,
        name: String?,
        email: String?
    ) {
        let string = """
                     Identify User
                     userId: \(userId)
                     name: \(name ?? "unknown")
                     email: \(email ?? "unknown")
                     """

        logger.log(.info, string)
    }

    func addUserProperties(properties: [String: Any]) {
        if !printParams { return }

        var string = """
                     Log User Properties
                     """

        let sortedKeys = properties.keys.sorted()

        for key in sortedKeys {
            if let value = properties[key] {
                string += "\n Key: \(key), Value: \(value)\n"
            }
        }

        logger.log(.info, string)
    }

    func deleteUserProfile() {
        if !printParams { return }

        let string = """
                     Delete User Profile
                     """

        logger.log(.warning, string)
    }

    func trackEvent(event: any LoggableEvent) {
        if !printParams { return }

        var string = """
                     \(event.eventName)
                     """

        if let parameters = event.parameters,
           !parameters.isEmpty {
            let sortedKeys = parameters.keys.sorted()

            for key in sortedKeys {
                if let value = parameters[key] {
                    string += "\n Key: \(key), Value: \(value)\n"
                }
            }
        }

        logger.log(event.type, string)
    }

    func trackScreenEvent(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
