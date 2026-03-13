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

    func badgeButtonModifier() -> some View {
        self
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.blue)
            .cornerRadius(10)
            .foregroundColor(.white)
    }

    func tappableBackground() -> some View {
        background(Color.black.opacity(0.001))
    }

    func removeListRowFormatting() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
    }

    func visibleGradientBackground() -> some View {
        background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.3)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    func chatBubbleModifier(textUIColor: UIColor, backgroundColor: Color) -> some View {
        self
            .foregroundStyle(Color(uiColor: textUIColor))
            .padding(13)
            .background(backgroundColor)
            .cornerRadius(10)
    }
}
