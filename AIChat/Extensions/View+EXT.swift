//
//  View+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

extension View {
    func callToActionButton() -> some View {
        self
            .modifier(CTAButtonViewModifier())
    }

    func tappableBackground() -> some View {
        self
            .background(Color.black.opacity(0.001))
    }
}
