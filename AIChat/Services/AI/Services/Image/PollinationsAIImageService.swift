//
//  PollinationsAIImageService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation
import SwiftUI

struct PollinationsAIImageService: AIImageService {
    func generateImage(input: String) async throws -> UIImage {
        let prompt = "\(input), hyperrealistic, photorealistic, 8K, DSLR, sharp focus, studio lighting, highly detailed"
        let safePrompt = prompt.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "avatar"
        let seed = Int.random(in: 1...100000)

        let urlString = "https://image.pollinations.ai/prompt/\(safePrompt)?width=512&height=512&nologo=true&seed=\(seed)&model=flux-realism"

        guard let url = URL(string: urlString) else { throw AIError.invalidImageData }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIError.noImageFound
        }

        guard let image = UIImage(data: data) else { throw AIError.invalidImageData }
        return image
    }
}
