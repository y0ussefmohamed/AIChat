//
//  CategoryListView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(AvatarManager.self) private var avatarManager
    var category: CharacterOption?
    var categoryImageName: String = Constants.randomImage
    @State private var avatars: [Avatar] = []
    @State private var alert: AnyAppAlert?

    @State private var isLoading: Bool = true

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

            if isLoading {
                ForEach(0..<5, id: \.self) { _ in
                    CustomListCellView(
                        avatarName: "Loading Name",
                        avatarDescription: "This is a placeholder, to look like real data.",
                        imageName: Constants.randomImage
                    )
                    .redacted(reason: .placeholder)
                    .removeListRowFormatting()
                }
            } else {
                if !avatars.isEmpty {
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
                } else {
                    ContentUnavailableView(
                        "No \(category?.pluralRawValue.capitalized ?? "Avatars") Found",
                        systemImage: "person.fill.xmark",
                        description: Text("There are no avatars in this category yet. Check back later!")
                    )
                    .listRowSeparator(.hidden)
                }

            }
        }
        .onAppear {
            loadCategoryAvatars()
        }
        .showCustomAlert(alert: $alert)
        .ignoresSafeArea()
        .listStyle(.plain)
    }

    private func loadCategoryAvatars() {
        Task {
            defer { isLoading = false }

            do {
                if let category {
                    avatars = try await avatarManager.getAvatarsByCategory(category)
                }
            } catch {
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func onRowTap(_ avatarId: String) {
        navPathStack.append(.chat(avatarId))
    }
}

#Preview("Has Data") {
    CategoryListView(category: .man, navPathStack: .constant([]))
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 2))))
}

#Preview("No Data") {
    CategoryListView(category: .woman, navPathStack: .constant([]))
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(avatars: [], delay: 1))))
}
