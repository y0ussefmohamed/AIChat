//
//  AITextService.swift
//  AIChat
//
//  Created by Youssef Mohamed on 20/04/2026.
//

import Foundation
import SwiftUI

protocol AITextService: Sendable {
    func generateText(input: String) async throws -> String
}
