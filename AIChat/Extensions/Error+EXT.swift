//
//  Error+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 01/09/2026.
//

import Foundation

extension Error {
    var asEventParameter: [String: Any] {
        [
            "error_description": "\(self.localizedDescription)"
        ]
    }
}
