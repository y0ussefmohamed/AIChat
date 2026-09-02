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

/// This means we need to make a `ViewBuilder` in order to fetch those Models with the avatarId and chatId to get our desired data, and we can't do this here because we can't make .task{} in each item in the for loop, we don't want to load the view unless we have the data to show

struct UserChatsView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(UserManager.self) private var userManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AvatarManager.self) private var avatarManager
    @State private var chats: [Chat] = []
    @State private var recentAvatars: [Avatar] = []
    @State private var isLoading: Bool = true

    @Binding var selectedTab: AppTap
    @State private var navPathStack: [String] = []

    var body: some View {
        NavigationStack(path: $navPathStack) {
            List {
                if isLoading {
                    loadingView
                } else if chats.isEmpty {
                    emptyChatsView
                } else {
                    if !recentAvatars.isEmpty {
                        recentsSection
                    }

                    chatsSection
                }
            }
            .screenAppearAnalytics(viewName: "UserChatsView")
            .navigationTitle("Chats")
            .task {
                await loadChats()
                await loadRecentsAvatars()
                isLoading = false
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
                    ChatRowCellViewBuilder(
                        currentUserId: nil,
                        getAvatar: { Avatar.mock },
                        streamLastMessage: { _ in }
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
                    logManager.trackEvent(event: UserChatsViewEvent.exploreAvatarsPressed)
                    selectedTab = .explore
                }
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
        let currentUserId = userManager.currentUser?.userId

        return Section {
            ForEach(chats) { chat in
                /// use a ViewBuilder wrapper when the view of the for loop depends on its items (the chat item in our case)
                ChatRowCellViewBuilder(
                    currentUserId: currentUserId,
                    getAvatar: {
                        await getAvatarForCell(chat.avatarId)
                    },
                    streamLastMessage: { onUpdate in
                        await streamLastMessageForCell(
                            chatId: chat.id,
                            onUpdate: onUpdate
                        )
                    }
                )
                .styledButton {
                    onRowTap(for: chat)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Chats")
        }
    }

    private func loadRecentsAvatars() async {
        logManager.trackEvent(event: UserChatsViewEvent.loadRecentsStart)
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: UserChatsViewEvent.loadRecentsSuccess(count: recentAvatars.count))
        } catch {
            logManager.trackEvent(event: UserChatsViewEvent.loadRecentsFail(error: error))
            print(error)
        }
    }

    private func loadChats() async {
        logManager.trackEvent(event: UserChatsViewEvent.loadChatsStart)
        do {
            if let uid = userManager.currentUser?.userId {
                chats = try await chatManager.loadChats(userId: uid)
                chats.sort(by: { $0.dateModified > $1.dateModified })
                logManager.trackEvent(event: UserChatsViewEvent.loadChatsSuccess(count: chats.count))
            }
        } catch {
            logManager.trackEvent(event: UserChatsViewEvent.loadChatsFail(error: error))
            print(error)
        }
    }

    private func getAvatarForCell(_ avatarId: String) async -> Avatar? {
        do {
            return try await avatarManager.getAvatar(id: avatarId)
        } catch {
            logManager.trackEvent(event: UserChatsViewEvent.loadCellAvatarFail(error: error))
            print(error)
        }
        return nil
    }

    /// Continuously streams chat changes and calls `onUpdate` every time a new value is emitted
    /// This keeps the cell in sync with the latest message and seen status in real-time
    private func streamLastMessageForCell(chatId: String, onUpdate: @escaping @MainActor (ChatMessage?) -> Void) async {
        do {
            for try await value in chatManager.streamChatChanges(chatId: chatId) {
                let messages = value.sorted(by: { $0.dateCreatedCalculated < $1.dateCreatedCalculated })
                onUpdate(messages.last)
            }
        } catch {
            logManager.trackEvent(event: UserChatsViewEvent.streamLastMessageFail(error: error))
            print(error)
        }
    }

    private func onRowTap(for chat: Chat) {
        logManager.trackEvent(event: UserChatsViewEvent.chatRowPressed(chat: chat))
        navPathStack.append(chat.avatarId)
    }

    private func onRecentsAvatarTap(avatarId: String) {
        logManager.trackEvent(event: UserChatsViewEvent.recentAvatarPressed(avatarId: avatarId))
        navPathStack.append(avatarId)
    }
}

extension UserChatsView {
    enum UserChatsViewEvent: LoggableEvent {
        case loadChatsStart, loadChatsSuccess(count: Int), loadChatsFail(error: Error)
        case loadRecentsStart, loadRecentsSuccess(count: Int), loadRecentsFail(error: Error)
        case chatRowPressed(chat: Chat)
        case recentAvatarPressed(avatarId: String)
        case exploreAvatarsPressed
        case loadCellAvatarFail(error: Error)
        case streamLastMessageFail(error: Error)

        var eventName: String {
            switch self {
            case .loadChatsStart:
                return "UserChatsView_LoadChats_Start"
            case .loadChatsSuccess:
                return "UserChatsView_LoadChats_Success"
            case .loadChatsFail:
                return "UserChatsView_LoadChats_Fail"
            case .loadRecentsStart:
                return "UserChatsView_LoadRecents_Start"
            case .loadRecentsSuccess:
                return "UserChatsView_LoadRecents_Success"
            case .loadRecentsFail:
                return "UserChatsView_LoadRecents_Fail"
            case .chatRowPressed:
                return "UserChatsView_ChatRow_Pressed"
            case .recentAvatarPressed:
                return "UserChatsView_RecentAvatar_Pressed"
            case .exploreAvatarsPressed:
                return "UserChatsView_ExploreAvatars_Pressed"
            case .loadCellAvatarFail:
                return "UserChatsView_LoadCellAvatar_Fail"
            case .streamLastMessageFail:
                return "UserChatsView_StreamLastMessage_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadChatsFail(error: let error),
                 .loadRecentsFail(error: let error),
                 .loadCellAvatarFail(error: let error),
                 .streamLastMessageFail(error: let error):
                return error.asEventParameter

            case .loadChatsSuccess(count: let count):
                return count.asEventParameter(key: "chats_count")

            case .loadRecentsSuccess(count: let count):
                return count.asEventParameter(key: "recents_count")

            case .chatRowPressed(chat: let chat):
                return chat.asEventParameter

            case .recentAvatarPressed(avatarId: let avatarId):
                return avatarId.asEventParamter(key: "avatar_id")

            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadChatsFail, .loadRecentsFail, .loadCellAvatarFail, .streamLastMessageFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    UserChatsView(selectedTab: .constant(.chats))
        .environment(LogManager(services: [ConsoleService()]))
        .environment(ChatManager(service: MockChatService()))
        .environment(
            AvatarManager(
                services: MockAvatarServices(
                    remote: MockAvatarService(avatars: Avatar.mocks, delay: 2),
                    local: MockLocalAvatarPersistence()
                )
            )
        )
        .previewEnvironment()
}
