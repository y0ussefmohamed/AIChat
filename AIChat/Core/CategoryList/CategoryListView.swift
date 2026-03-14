//
//  CategoryListView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import SwiftUI

struct CategoryListView: View {
    var category: CharacterOption? = .alien
    var categoryImageName: String = Constants.randomImage
    @State private var avatars: [Avatar] = Avatar.mocks

    /// We did this because:
    /// This View is in a `NavigationStack` already, so we can bind the navPathStack from this View to the navPathStack that's in the previous NavigationStack (Which this View came from)
    @Binding var navPathStack: [NavigationPathOption]
    var body: some View {
        List {
            CategoryCellView(
                title: category?.pluralRawValue.capitalized,
                imageName: categoryImageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()

            ForEach(avatars, id: \.self) { avatar in
                CustomListCellView(
                    avatarName: avatar.name,
                    avatarDescription: avatar.characterDescription,
                    imageName: avatar.profileImageName
                )
                .styledButton(.highlighted) {
                    onRowTap(avatar.avatarId)
                }
                .removeListRowFormatting()
            }

        }
        .ignoresSafeArea()
        .listStyle(.plain)
    }

    private func onRowTap(_ avatarId: String) {
        navPathStack.append(.chat(avatarId))
    }
}

#Preview {
    CategoryListView(navPathStack: .constant([]))
}
