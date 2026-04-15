//
//  AIManager.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation
import SwiftUI
import Combine


@MainActor
@Observable
class AIManager {
    private let service: AIService

    init(service: AIService) {
        self.service = service
    }

    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
}
