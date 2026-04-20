//
//  TypingIndicatorView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 20/04/2026.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var animatingDot = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 10, height: 10)
                    .scaleEffect(animatingDot == index ? 1.4 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.4).repeatForever(autoreverses: true),
                        value: animatingDot
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(uiColor: .systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            animateDots()
        }
    }

    private func animateDots() {
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                animatingDot = i
            }
        }
    }
}

#Preview {
    TypingIndicatorView()
}
