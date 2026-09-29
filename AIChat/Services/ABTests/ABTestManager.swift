//
//  ABTestManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

@MainActor @Observable
class ABTestManager {
    private let service: ABTestService
    private let logManager: LogManager?

    var activeTests: ActiveABTests

    init(service: ABTestService, logManager: LogManager? = nil) {
        self.service = service
        self.activeTests = service.activeTests /// to achieve encapuslation and access this instead of accessing the whole service
        self.logManager = logManager
        
        self.configureUserProperties()
    }

    private func configureUserProperties() {
        activeTests = service.activeTests
        logManager?.addUserProperties(properties: activeTests.asEventParamaters, isHighPriority: false)
    }

    func override(updatedTests: ActiveABTests) throws {
        try service.saveUpdatedConfig(updatedTests: updatedTests)
        configureUserProperties()
    }
}
