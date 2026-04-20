//
//  MockAITextService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 20/04/2026.
//


import Foundation
import SwiftUI

struct MockAITextService: AITextService {
    func generateText(input: String) async throws -> String {
        "Mock generated text for: \(input)"
    }
}
