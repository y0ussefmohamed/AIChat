//
//  AIImageService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/04/2026.
//

import Foundation
import SwiftUI

protocol AIImageService: Sendable {
    func generateImage(input: String) async throws -> UIImage
}
