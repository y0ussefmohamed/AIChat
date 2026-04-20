//
//  AIServicesContainer.swift
//  AIChat
//
//  Created by Youssef Mohamed on 20/04/2026.
//

import Foundation

protocol AIServicesContainer {
    var imageService: AIImageService { get }
    var textService: AITextService { get }
}

struct MockAIServices: AIServicesContainer {
    let imageService: AIImageService = MockAIImageService()
    let textService: AITextService = MockAITextService()
}

struct ProductionAIServices: AIServicesContainer {
    let imageService: AIImageService = PollinationsAIImageService()
    let textService: AITextService = GroqAITextService()
}
