//
//  ExploreView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ExploreView: View {
    @Environment(AvatarManager.self) private var avatarManager
    @State private var featuredAvatars: [Avatar] = []
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var popularAvatars: [Avatar] = []
    @State private var alert: AnyAppAlert?

    @State private var navPathStack: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $navPathStack) {
            List {
                featuredSection

                if popularAvatars.isEmpty {
                    ProgressView()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    categoriesSection
                    popularSection
                }
            }
            .showCustomAlert(alert: $alert)
            .navigationTitle("Explore")
            .navigationDestination(for: NavigationPathOption.self) { pathOptionTop in
                switch pathOptionTop {
                case .chat(let avatarId):
                    ChatView(avatarId: avatarId)
                case .category(let category, let imageName):
                    CategoryListView(category: category, categoryImageName: imageName, navPathStack: $navPathStack)
                }
            }
            .onFirstAppear {
                loadFeaturedAvatars()
                loadPopularAvatars()
            }
        }
    }
}

extension ExploreView {
    private var featuredSection: some View {
        Section {
            if featuredAvatars.isEmpty {
                ProgressView()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
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
            }

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

    private func loadFeaturedAvatars() {
        Task {
            do {
                featuredAvatars = try await avatarManager.getFeaturedAvatars()
            } catch {
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func loadPopularAvatars() {
        Task {
            do {
                popularAvatars = try await avatarManager.getPopularAvatars()
            } catch {
                alert = AnyAppAlert(error: error)
            }
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
        .environment(AvatarManager(service: MockAvatarService()))
}
