//
//  CategoryListView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import SwiftUI

struct CategoryListView: View {
    @State var viewModel: CategoryListViewModel

    var category: CharacterOption?
    var categoryImageName: String = Constants.randomImage
    @Binding var navPathStack: [NavigationPathOption]

    var body: some View {
        List {
            CategoryCellView(
                title: category?.pluralRawValue.capitalized,
                imageName: categoryImageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .accessibilityIdentifier(AccessibilityID.Category.title)
            .removeListRowFormatting()

            if viewModel.isLoading {
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
                if !viewModel.avatars.isEmpty {
                    ForEach(viewModel.avatars, id: \.self) { avatar in
                        CustomListCellView(
                            avatarName: avatar.name,
                            avatarDescription: avatar.characterDescription,
                            imageName: avatar.profileImageName
                        )
                        .styledButton(.highlighted) {
                            viewModel.onRowTap(avatar.avatarId, navPathStack: &navPathStack)
                        }
                        .accessibilityIdentifier(AccessibilityID.Category.avatar(avatar.avatarId))
                        .removeListRowFormatting()
                    }
                } else {
                    ContentUnavailableView(
                        "No \(category?.pluralRawValue.capitalized ?? "Avatars") Found",
                        systemImage: "person.fill.xmark",
                        description: Text("There are no avatars in this category yet. Check back later!")
                    )
                    .accessibilityIdentifier(AccessibilityID.Category.empty)
                    .listRowSeparator(.hidden)
                }

            }
        }
        .accessibilityIdentifier(AccessibilityID.Category.list)
        .task {
            await viewModel.loadCategoryAvatars(category: category)
        }
        .screenAppearAnalytics(viewName: "CategoryListView")
        .showCustomAlert(alert: $viewModel.alert)
        .ignoresSafeArea()
        .listStyle(.plain)
    }
}

#Preview("Has Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 2))))

    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), category: .man, navPathStack: .constant([]))
        .previewEnvironment()
}


#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(services: MockAvatarServices(remote: MockAvatarService(avatars: [], delay: 1))))

    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), category: .woman, navPathStack: .constant([]))
        .previewEnvironment()
}
