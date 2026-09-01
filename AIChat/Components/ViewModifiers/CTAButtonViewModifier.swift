//
//  CTAButtonViewModifier.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct CTAButtonViewModifier: ViewModifier {
    let buttonColor: Color

    init(buttonColor: Color = .accent) {
        self.buttonColor = buttonColor
    }

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(buttonColor)
            .cornerRadius(16)
    }
}
