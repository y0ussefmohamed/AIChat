//
//  Color+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 10/03/2026.
//

import SwiftUI
import UIKit

extension Color {

    // Initialize Color from hex string
    init?(hex: String) {
            let hex = hex
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "#", with: "")

            guard let value = UInt64(hex, radix: 16) else {
                return nil
            }

            let red: Double
            let green: Double
            let blue: Double
            let opacity: Double

            switch hex.count {
            case 6:
                red = Double((value >> 16) & 0xFF) / 255
                green = Double((value >> 8) & 0xFF) / 255
                blue = Double(value & 0xFF) / 255
                opacity = 1

            case 8:
                red = Double((value >> 24) & 0xFF) / 255
                green = Double((value >> 16) & 0xFF) / 255
                blue = Double((value >> 8) & 0xFF) / 255
                opacity = Double(value & 0xFF) / 255

            default:
                return nil
            }

            self.init(
                .sRGB,
                red: red,
                green: green,
                blue: blue,
                opacity: opacity
            )
        }

    // Convert  to hex string
    func toHex() -> String {
    #if os(iOS)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        // getRed(_:green:blue:alpha:) automatically handles grayscale and RGB conversion
        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return String(
                format: "#%02X%02X%02X",
                Int(round(red * 255)),
                Int(round(green * 255)),
                Int(round(blue * 255))
            )
        }

        // Fallback for edge cases where color conversion fails
        return "#000000"
    #else
        // Fallback for non-iOS platforms
        return "#000000"
    #endif
    }
}
