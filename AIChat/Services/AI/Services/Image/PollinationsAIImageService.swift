//
//  PollinationsAIImageService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation
import SwiftUI

struct PollinationsAIImageService: AIImageService {
    private let primaryModel: String = "flux"
    private let fallbackModel: String = "sana"

    func generateImage(input: String) async throws -> UIImage {
        let prompt = "\(input), hyperrealistic, photorealistic, 8K, DSLR, sharp focus, studio lighting, highly detailed"
        let safePrompt = prompt.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "avatar"
        let seed = Int.random(in: 1...100000)

        // Try primary model (FLUX.1) first for highest quality
        if let image = try? await fetchImage(prompt: safePrompt, seed: seed, model: primaryModel) {
            return image
        }

        // Fall back to Sana (NVIDIA / MIT DiT) for speed and reliability if primary is busy
        if let image = try? await fetchImage(prompt: safePrompt, seed: seed, model: fallbackModel) {
            return image
        }

        throw AIError.noImageFound
    }

    private func fetchImage(prompt: String, seed: Int, model: String) async throws -> UIImage {
        let urlString = "https://image.pollinations.ai/prompt/\(prompt)?width=1024&height=1024&nologo=true&seed=\(seed)&model=\(model)"

        guard let url = URL(string: urlString) else { throw AIError.invalidImageData }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIError.noImageFound
        }

        guard let image = UIImage(data: data) else { throw AIError.invalidImageData }
        return image
    }
}
