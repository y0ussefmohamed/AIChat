//
//  ABTestService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 29/09/2026.
//

import Foundation

protocol ABTestService {
    var activeTests: ActiveABTests { get }
    func fetchUpdatedConfig() async throws -> ActiveABTests
}

protocol EditableABTestService: ABTestService {
    func saveUpdatedConfig(updatedTests: ActiveABTests) throws
}
