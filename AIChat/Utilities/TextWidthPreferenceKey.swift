//
//  TextWidthPreferenceKey.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/10/2026.
//

import Foundation
import SwiftUI

struct TextWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
