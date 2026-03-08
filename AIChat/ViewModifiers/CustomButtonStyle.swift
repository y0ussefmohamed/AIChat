//
//  CustomButtonStyle.swift
//  AIChat
//
//  Created by Youssef Mohamed on 08/03/2026.
//

import SwiftUI

/// A `ViewModifier` can work with any view as a normal modifier, but a `ButtonStyle` only works on buttons
struct HighlightedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label /// the button
            .overlay(
                configuration.isPressed ? Color.accent.opacity(0.4) : Color.clear
            )
            .cornerRadius(16)
            .animation(.smooth, value: configuration.isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            // .animation(.smooth, value: configuration.isPressed)
    }
}

enum ButtonStyleOption {
    case pressable, highlighted, plain
}

extension View {

    @ViewBuilder
    func styledButton(_ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
        switch option {
        case .pressable:
            self /// `self` is the view I did `.styledButton` from
                .asPressableButton(action: action)
        case .highlighted:
            self
                .asHighlightedButton(action: action)
        default:
            self
                .asPlainButton(action: action)
        }
    }

    private func asPlainButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self /// `self` is the view I did `.styledButton` from, so as if i wrapped the view in a button
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func asPressableButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(PressableButtonStyle())
    }

    private func asHighlightedButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self
        }
        .buttonStyle(HighlightedButtonStyle())
    }
}
