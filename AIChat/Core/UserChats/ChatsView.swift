//
//  ChatsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

// What do we need in this screen?
/// 1. The Avatar Model to get the image, username of the avatar that sent the message
/// 2. The ChatMessage Model to get the latest message and check if the user has seen the message or not

/// This means we need to make a `ViewBuilder` in order to fetch those Models with the avatarId and chatId to get our desired data, and we can't do this here because we can't make .task{} in each item in the for loop, we don't want to load the view unless we have the data to show

struct ChatsView: View {
    @State private var chats: [Chat] = Chat.mocks
    @State private var recentAvatars: [Avatar] = Avatar.mocks

    @State private var navPathStack: [String] = []
    var body: some View {
        NavigationStack(path: $navPathStack) {
            List {
                if chats.isEmpty {
                    emptyChatsView
                } else {
                    if !recentAvatars.isEmpty {
                        recentsSection
                    }

                    chatsSection
                }
            }
            .navigationTitle("Chats")
            .navigationDestination(for: String.self) { avatarId in
                ChatView(avatarId: avatarId)
            }
        }
    }

    private var emptyChatsView: some View {
        ContentUnavailableView {
            Label("No Chats Yet", systemImage: "bubble.left.and.bubble.right")
        } description: {
            Text("You haven't started any conversations. Pick an AI avatar and say hello!")
        } actions: {
            Button("Create Avatars") {
                print("Navigate to discovery...")
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .removeListRowFormatting()
    }

    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName, let name = avatar.name {
                            RecentsCellView(imageName: imageName, name: name)
                            .styledButton(.pressable) {
                                onRecentsAvatarTap(avatarId: avatar.avatarId)
                            }
                        }
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
    }

    private var chatsSection: some View {
        Section {
            ForEach(chats) { chat in
                /// use a `ViewBuilder` wrapper when the view of the for loop depends on its items (the `chat` item in our case)
                ChatRowCellViewBuilder(
                    currentUserId: nil,
                    chat: chat,
                    getAvatar: {
                        try? await Task.sleep(for: .seconds(1))
                        // Get Avatar by chat.avatarId
                        return .mocks.shuffled().last
                    },
                    getLastChatMessage: {
                        // Get Last Chat Message by chat.id
                        return .mock
                    }
                )
                .styledButton(.pressable) {
                    onRowTap(for: chat)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Chats")
        }
    }

    private func onRowTap(for chat: Chat) {
        navPathStack.append(chat.avatarId)
    }

    private func onRecentsAvatarTap(avatarId: String) {
        navPathStack.append(avatarId)
    }
}

#Preview {
    ChatsView()
}
