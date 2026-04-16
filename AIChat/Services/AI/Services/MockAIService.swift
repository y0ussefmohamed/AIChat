//
//  MockAIService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation
import SwiftUI

struct MockAIService: AIService {
    func generateImage(input: String) async throws -> UIImage {
        try await Task.sleep(for: .seconds(2))
        return UIImage(systemName: "star.fill")!
    }
}
