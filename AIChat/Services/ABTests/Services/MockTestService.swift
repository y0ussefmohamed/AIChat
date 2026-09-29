//
//  MockTestService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

struct MockABTestService: ABTestService {
    let activeTests: ActiveABTests

    init(createAccountTest: Bool? = nil) {
        self.activeTests = ActiveABTests(createAccountTest: createAccountTest ?? false)
    }
}
