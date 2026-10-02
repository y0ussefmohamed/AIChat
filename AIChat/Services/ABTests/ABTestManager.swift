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
    private let editableService: (any EditableABTestService)?
    private let logManager: LogManager?

    var canOverrideTests: Bool {
        editableService != nil
    }

    init(service: ABTestService, logManager: LogManager? = nil) {
        self.service = service
        self.editableService = service as? any EditableABTestService
        self.logManager = logManager

        self.activeTests = service.activeTests /// to achieve encapuslation and access this instead of accessing the whole service
        self.configureUserProperties()
    }

    private func configureUserProperties() {
        Task { [weak self] in
            guard let self else { return }

            do {
                self.activeTests = try await self.service.fetchUpdatedConfig()
            } catch {
                print(error)
            }
        }
        
        logManager?.addUserProperties(properties: activeTests.asEventParamaters, isHighPriority: false)
    }

    /// in order for this function to run the service should only be the `EditableABTestService`
    func override(updatedTests: ActiveABTests) throws {
        guard let editableService else {
            throw OverrideError.notSupported
        }

        try editableService.saveUpdatedConfig(updatedTests: updatedTests)
        activeTests = service.activeTests

        configureUserProperties()
    }
}

extension ABTestManager {
    enum OverrideError: LocalizedError {
        case notSupported

        var errorDescription: String? {
            "The current A/B test service does not support overrides."
        }
    }
}
