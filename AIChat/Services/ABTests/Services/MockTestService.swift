//
//  MockTestService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

class MockABTestService: ABTestService {
    var activeTests: ActiveABTests

    init(createAccountTest: Bool? = nil, onboardingCommunityTest: Bool? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false
        )
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }
}
