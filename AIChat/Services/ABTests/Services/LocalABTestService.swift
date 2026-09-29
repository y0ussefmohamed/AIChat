//
//  LocalABTestService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

class LocalABTestService: ABTestService {
    @UserDefault(key: ActiveABTests.CodingKeys.createAccountTest.rawValue, startingValue: Bool.random())
    private var createAccountTest: Bool

    var activeTests: ActiveABTests {
        ActiveABTests(createAccountTest: createAccountTest)
    }

    func saveUpdatedConfig(updatedTests: ActiveABTests) throws {
        createAccountTest = updatedTests.createAccountTest
    }
}
