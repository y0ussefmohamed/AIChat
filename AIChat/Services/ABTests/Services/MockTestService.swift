//
//  MockTestService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

class MockABTestService: EditableABTestService {
    var activeTests: ActiveABTests

    init(createAccountTest: Bool? = nil, onboardingCommunityTest: Bool? = nil, categoryRowTest: CategoryRowTestOption? = nil) {
        self.activeTests = ActiveABTests(
            createAccountTest: createAccountTest ?? false,
            onboardingCommunityTest: onboardingCommunityTest ?? false,
            categoryRowTest: categoryRowTest ?? .default
        )
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        activeTests = updatedTests
    }

    func fetchUpdatedConfig() async throws -> ActiveABTests {
        activeTests
    }
}
