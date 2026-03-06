//
//  CarouselView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 06/03/2026.
//

import SwiftUI

struct CarouselView: View {
    var avatars: [Avatar] = Avatar.mocks
    @State private var selectedAvatarIndex: Int? = 0

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(avatars.enumerated()), id: \.offset) { index, avatar in
                        Rectangle()
                            .fill(Color.black.opacity(0.001))
                            .containerRelativeFrame(.horizontal) /// take full width in paging
                            .overlay {
                                HeroCellView(
                                    imageName: avatar.profileImageName,
                                    title: avatar.name,
                                    subtitle: avatar.characterDescription
                                )
                                .scrollTransition(.interactive.threshold(.visible(0.7)), transition: { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                })
                            }
                            .id(index) /// give each rectangle an `id`
                            /// this means when the scroll is happening this id is changing and since it is binded to `$selectedAvatarIndex` in the `scrollPosition` so `selectedAvatarIndex` is also changing
                    }
                }
            }
            .frame(height: 200)
            .scrollIndicators(.hidden)
            /// Add Paging Effect
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            /// To track which one page we are in right now
            .scrollPosition(id: $selectedAvatarIndex) /// $selectedAvatarIndex binded to the id
            .onAppear { updateSelectionIfNeeded() }

            HStack(spacing: 8) {
                ForEach(Array(avatars.enumerated()), id: \.offset) { index, _ in
                    Circle()
                        .fill(index == selectedAvatarIndex ? Color.accentColor : Color.secondary.opacity(0.6))
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selectedAvatarIndex)
        }
    }

    private func updateSelectionIfNeeded() {
        if selectedAvatarIndex == nil || selectedAvatarIndex == avatars.count - 1 {
            selectedAvatarIndex = 0
        }
    }
}

#Preview {
    CarouselView()
}
