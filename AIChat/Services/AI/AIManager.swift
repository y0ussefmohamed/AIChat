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
    private let imageService: AIImageService
    private let textService: AITextService

    init(aiServices: AIServicesContainer) {
        self.imageService = aiServices.imageService
        self.textService = aiServices.textService
    }

    func generateImage(input: String) async throws -> UIImage {
        try await imageService.generateImage(input: input)
    }

    func generateText(input: String) async throws -> String {
        try await textService.generateText(input: input)
    }
}
