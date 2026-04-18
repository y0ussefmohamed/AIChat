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
    @State private var featuredDidLoad: Bool = false
    @State private var popularDidLoad: Bool = false

    @State private var navPathStack: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $navPathStack) {
            List {
                if !featuredDidLoad {
                    loadingIndicator
                } else {
                    if !featuredAvatars.isEmpty {
                        featuredSection
                    } else {
                        ContentUnavailableView(
                            "No Featured Avatars",
                            systemImage: "sparkles.slash",
                            description: Text("There are no featured avatars at the moment.")
                        )
                        .frame(height: 200)
                        .removeListRowFormatting()
                    }
                }


                if !popularDidLoad {
                    loadingIndicator
                } else {
                    if !popularAvatars.isEmpty {
                        categoriesSection
                        popularSection
                    } else {
                        ContentUnavailableView(
                                "No Popular Avatars Available",
                                systemImage: "person.fill.xmark",
                                description: Text("There are no popular avatars at the moment. Check back later!")
                            )
                            .frame(height: 200)
                            .removeListRowFormatting()
                    }
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
    private var loadingIndicator: some View {
        ProgressView()
            .frame(height: 200)
            .frame(maxWidth: .infinity, alignment: .center)
            .removeListRowFormatting()
    }
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

    private func retryButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("Try Again")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.accentColor, in: Capsule())
        }
        .padding(.bottom, 8)
    }

    private var categoriesSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        let imageName = popularAvatars.last(
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
        featuredDidLoad = false
        Task {
            do {
                featuredAvatars = try await avatarManager.getFeaturedAvatars()
                featuredDidLoad = true
            } catch {
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func loadPopularAvatars() {
        popularDidLoad = false
        Task {
            do {
                popularAvatars = try await avatarManager.getPopularAvatars()
                popularDidLoad = true
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

#Preview("Has Data") {
    ExploreView()
        .environment(AvatarManager(services: MockAvatarServices()))
}

#Preview("No Data") {
    ExploreView()
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(avatars: [], delay: 3))))
}


#Preview("Slow Loading") {
    ExploreView()
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 4))))
}
