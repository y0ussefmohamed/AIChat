//
//  View+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

extension View {
    func callToActionButton(buttonColor: Color = .accent) -> some View {
        self
            .modifier(CTAButtonViewModifier(buttonColor: buttonColor))
    }

    func tappableBackground() -> some View {
        self
            .background(Color.black.opacity(0.001))
    }
}
