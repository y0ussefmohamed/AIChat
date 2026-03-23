//
//  ExploreView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ExploreView: View {
    @State private var featuredAvatars: [Avatar] = Avatar.mocks
    @State private var categories: [CharacterOption] = CharacterOption.allCases + CharacterOption.allCases
    @State private var popularAvatars: [Avatar] = Avatar.mocks

    @State private var navPathStack: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $navPathStack) {
            List {
                featuredSection

                categoriesSection

                popularSection
            }
            .navigationTitle("Explore")
            .navigationDestination(for: NavigationPathOption.self) { pathOptionTop in
                switch pathOptionTop {
                case .chat(let avatarId):
                    ChatView(avatarId: avatarId)
                case .category(let category, let imageName):
                    CategoryListView(category: category, categoryImageName: imageName, navPathStack: $navPathStack)
                }
            }
        }
    }
}

extension ExploreView {
    private var featuredSection: some View {
        Section {
            CarouselView(items: featuredAvatars) { avatar in
                HeroCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription,
                )
                .styledButton {
                    onAvatarPressed(avatar.avatarId)
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }

    private var categoriesSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        let imageName = popularAvatars.first(
                            where: {
                                $0.characterOption == category
                            })?.profileImageName

                        if let imageName {
                            CategoryCellView(
                                title: category.pluralRawValue.capitalized,
                                imageName: imageName
                            )
                            .styledButton(.pressable) {
                                onCategoryPressed(category, imageName)
                            }
                        }
                    }
                }
                .frame(height: 150)
            }
            .scrollIndicators(.never)
            /// Page like scrolling
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }

    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    avatarName: avatar.name,
                    avatarDescription: avatar.characterDescription,
                    imageName: avatar.profileImageName
                )
                .styledButton(.highlighted) {
                    onAvatarPressed(avatar.avatarId)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }

    private func onAvatarPressed(_ avatarId: String) {
        navPathStack.append(.chat(avatarId))
    }

    private func onCategoryPressed(_ category: CharacterOption, _ imageName: String) {
        navPathStack.append(.category(category, imageName))
    }
}

#Preview {
    ExploreView()
}
