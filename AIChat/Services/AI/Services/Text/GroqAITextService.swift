//
//  GroqAITextService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 20/04/2026.
//

import Foundation

struct GroqAITextService: AITextService {
    private let apiKey: String = ""
    private let model: String = "llama-3.3-70b-versatile"
    private let baseURL = "https://api.groq.com/openai/v1/chat/completions"

    func generateText(input: String) async throws -> String {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "user",
                    "content": input
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 1024
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Status Code: \(httpResponse.statusCode)")
        }
        print("📦 Raw Response: \(String(data: data, encoding: .utf8) ?? "nil")")

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let rawError = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "GroqAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: rawError])
        }

        let jsonResponse = try JSONDecoder().decode(GroqResponse.self, from: data)

        guard let content = jsonResponse.choices.first?.message.content else {
            throw NSError(domain: "GroqAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No content in response"])
        }

        return content
    }
}

// MARK: - Response Models
struct GroqResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}
