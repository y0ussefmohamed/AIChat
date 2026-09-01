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

    private var showDevSettingsViews: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }

    @State private var showDevSettings: Bool = false

    @State private var navPathStack: [NavigationPathOption] = []
    var body: some View {
        NavigationStack(path: $navPathStack) {
            List {
                if !featuredDidLoad {
                    featuredLoadingView
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
                    categoriesLoadingView
                    popularLoadingView
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
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsViews {
                        devSettingsButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings) {
                DevSettingsView()
            }
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
    private var featuredLoadingView: some View {
        Section {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.25))
                    .frame(height: 200)

                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 140, height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 220, height: 12)
                }
                .padding(16)
            }
            .padding(.horizontal)
            .shimmering()
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }

    private var categoriesLoadingView: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(0..<5, id: \.self) { _ in
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.25))
                                .frame(width: 140, height: 150)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.35))
                                .frame(width: 80, height: 12)
                                .padding(12)
                        }
                        .shimmering()
                    }
                }
                .frame(height: 150)
            }
            .scrollIndicators(.never)
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }

    private var popularLoadingView: some View {
        Section {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 60, height: 60)

                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.25))
                            .frame(width: 140, height: 14)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.25))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.25))
                            .frame(maxWidth: 200)
                            .frame(height: 12)
                    }

                    Spacer(minLength: 0)
                }
                .padding(.vertical, 8)
                .shimmering()
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
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
        var nilStr: String? = nil
        let forceCrash: String = nilStr!

        navPathStack.append(.chat(avatarId))
    }

    private func onCategoryPressed(_ category: CharacterOption, _ imageName: String) {
        navPathStack.append(.category(category, imageName))
    }

    private var devSettingsButton: some View {
        Text("DEV")
            .foregroundStyle(.blue)
            .styledButton(.plain) {
                onDevSettingsPressed()
            }
    }

    private func onDevSettingsPressed() {
        showDevSettings.toggle()
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
