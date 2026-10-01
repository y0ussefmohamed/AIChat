//
//  ABTestManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

@MainActor @Observable
class ABTestManager {
    private(set) var activeTests: ActiveABTests /// accessing active tests from here

    private let service: ABTestService
    private let logManager: LogManager?

    init(service: ABTestService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager

        self.activeTests = service.activeTests /// to achieve encapuslation and access this instead of accessing the whole service
        self.configureUserProperties()
    }

    private func configureUserProperties() {
        logManager?.addUserProperties(properties: activeTests.asEventParamaters, isHighPriority: false)
    }

    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        activeTests = service.activeTests

        configureUserProperties()
    }
}
