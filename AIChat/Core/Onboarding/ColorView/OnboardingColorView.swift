//
//  OnboardingColorView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 05/03/2026.
//

import SwiftUI

struct OnboardingColorView: View {
    @State private var selectedColorIdx: Int?
    let profileColors: [Color] = [.red, .green, .orange, .blue, .mint, .purple, .cyan, .teal, .indigo]

    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: 16) {
            if selectedColorIdx != nil {
                ZStack {
                    ctaButton
                        .background(Color(.systemBackground))
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}

extension OnboardingColorView {
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders],
            content: {
                Section(content: {
                    ForEach(profileColors.indices, id: \.self) { colorIdx in
                        Circle()
                            .fill(.accent)
                            .overlay(
                                Circle()
                                    .fill(profileColors[colorIdx])
                                    .padding(selectedColorIdx == colorIdx ? 10 : 0)
                            )
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    selectedColorIdx = colorIdx
                                }
                            }
                    }
                }, header: {
                    Text("Select a Profile Color")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                })
            }
        )
    }

    private var ctaButton: some View {
        NavigationLink {
            OnboardingCompletedView()
        } label: {
            Text("Continue")
                .callToActionButton()
                .padding(16)
        }
    }
}

#Preview {
    OnboardingColorView()
}
