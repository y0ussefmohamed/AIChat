//
//  UserChatsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

// What do we need in this screen?
/// 1. The Avatar Model to get the image, username of the avatar that sent the message
/// 2. The ChatMessage Model to get the latest message and check if the user has seen the message or not

/// Each row uses a `ViewBuilder` wrapper to fetch these models and own its loading state and tasks.

struct UserChatsView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: UserChatsViewModel

    @Binding var selectedTab: AppTap

    var body: some View {
        NavigationStack(path: $viewModel.navPathStack) {
            List {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.chats.isEmpty {
                    emptyChatsView
                } else {
                    if !viewModel.recentAvatars.isEmpty {
                        recentsSection
                    }

                    chatsSection
                }
            }
            .accessibilityIdentifier(AccessibilityID.Chats.list)
            .screenAppearAnalytics(viewName: "UserChatsView")
            .navigationTitle("Chats")
            .task {
                await viewModel.loadData()
            }
            .navigationDestination(for: String.self) { avatarId in
                ChatView(avatarId: avatarId)
            }
        }
    }

    private var loadingView: some View {
        Group {
            Section {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { _ in
                            RecentsCellView(imageName: "placeholder", name: "Loading")
                        }
                    }
                    .padding(.top, 10)
                }
                .frame(height: 120)
                .scrollIndicators(.hidden)
                .removeListRowFormatting()
            } header: {
                Text("Recents")
            }

            Section {
                ForEach(0..<5, id: \.self) { _ in
                    ChatRowCellView(
                        imageName: Avatar.mock.profileImageName,
                        headline: ".... ....",
                        subheadline: ".... .... .... ...."
                    )
                    .removeListRowFormatting()
                }
            } header: {
                Text("Chats")
            }
        }
        .redacted(reason: .placeholder)
        .disabled(true)
    }

    private var emptyChatsView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 100, height: 100)

                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.accentColor)
                }

                VStack(spacing: 8) {
                    Text("No conversations yet")
                        .accessibilityIdentifier(AccessibilityID.Chats.empty)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Browse AI avatars and start\nyour first conversation.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                    Text("Explore Avatars")
                }
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accentColor, in: Capsule())
                .styledButton {
                    viewModel.onExploreAvatarsPressed()
                    selectedTab = .explore
                }
                .accessibilityIdentifier(AccessibilityID.Chats.explore)
                .padding(.top, 4)
            }
            .padding(.vertical, 60)
            .frame(maxWidth: .infinity)
        }
        .removeListRowFormatting()
    }

    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName, let name = avatar.name {
                            RecentsCellView(imageName: imageName, name: name)
                            .styledButton(.pressable) {
                                viewModel.onRecentsAvatarTap(avatarId: avatar.avatarId)
                            }
                            .accessibilityIdentifier(AccessibilityID.Chats.recent(avatar.avatarId))
                        }
                    }
                }
                .padding(.top, 10)
            }
            .frame(height: 120)
            .accessibilityIdentifier(AccessibilityID.Chats.recents)
            .scrollIndicators(.hidden)
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }

    private var chatsSection: some View {
        Section {
            ForEach(viewModel.chats) { chat in
                /// use a ViewBuilder wrapper when the view of the for loop depends on its items (the chat item in our case)
                ChatRowCellViewBuilder(
                    viewModel: ChatRowCellViewModel(
                        interactor: CoreInteractor(container: container),
                        chatId: chat.id,
                        avatarId: chat.avatarId
                    )
                )
                .styledButton {
                    viewModel.onRowTap(for: chat)
                }
                .accessibilityIdentifier(AccessibilityID.Chats.row(chat.id))
                .removeListRowFormatting()
            }
        } header: {
            Text("Chats")
        }
    }
}

// MARK: - Preview

#Preview {
    let container = DevPreview.shared.container
    let logManager = LogManager(services: [ConsoleService()])
    let chatManager = ChatManager(service: MockChatService())
    let avatarManager = AvatarManager(
        services: MockAvatarServices(
            remote: MockAvatarService(avatars: Avatar.mocks, delay: 2),
            local: MockLocalAvatarPersistence()
        )
    )
    container.register(LogManager.self, service: logManager)
    container.register(ChatManager.self, service: chatManager)
    container.register(AvatarManager.self, service: avatarManager)

    return UserChatsView(
        viewModel: UserChatsViewModel(interactor: CoreInteractor(container: container)),
        selectedTab: .constant(.chats)
    )
        .previewEnvironment()
        .environment(container)
        .environment(logManager)
        .environment(chatManager)
        .environment(avatarManager)
}
