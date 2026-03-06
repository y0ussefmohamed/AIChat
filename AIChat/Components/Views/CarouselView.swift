//
//  CarouselView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 06/03/2026.
//

import SwiftUI

struct CarouselView<T: Hashable, PagingContent: View>: View {
    var items: [T]
    @ViewBuilder var pagingContent: (T) -> PagingContent
    @State private var selectedItem: T?

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        Rectangle()
                            .fill(Color.black.opacity(0.001))
                            .containerRelativeFrame(.horizontal) /// take full width in paging
                            .overlay {
                                pagingContent(item)
                                .scrollTransition(.interactive.threshold(.visible(0.7)), transition: { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                })
                            }
                            .id(item) /// give each rectangle an `id`
                            /// this means when the scroll is happening this id is changing and since it is binded to `$selectedItem` in the `scrollPosition` so `selectedItem` is also changing
                    }
                }
            }
            .frame(height: 200)
            .scrollIndicators(.hidden)
            /// Add Paging Effect
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            /// To track which one page we are in right now
            .scrollPosition(id: $selectedItem) /// $selectedItem binded to the id
            .onAppear { updateSelectionIfNeeded() }

            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Circle()
                        .fill(item == selectedItem ? Color.accentColor : Color.secondary.opacity(0.6))
                        .frame(width: 8, height: 8)
                }
            }
            .animation(.linear, value: selectedItem)
        }
    }

    private func updateSelectionIfNeeded() {
        if selectedItem == nil || selectedItem == items.last {
            selectedItem = items.first
        }
    }
}

#Preview {
    CarouselView(items: Avatar.mocks) { avatar in
        HeroCellView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterDescription
        )
    }
}
