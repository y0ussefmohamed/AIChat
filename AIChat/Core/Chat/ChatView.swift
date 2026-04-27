//
//  ChatView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

struct ChatView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AIManager.self) private var aiManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(\.dismiss) private var dismiss
    @State private var chat: Chat?
    @State private var chatMessages: [ChatMessage] = []
    @State private var avatar: Avatar?
    @State private var currentUser: UserModel?
    @State private var messageTextField: String = ""
    @State private var showConfirmationDialog: Bool = false
    @State private var scrollPositionId: String?
    @State private var showProfileModal: Bool = false
    @State private var isAvatarTyping: Bool = false
    @State private var alert: AnyAppAlert?
    @State private var isLoading: Bool = true

    @State private var isUserInThisScreen: Bool = false

    var avatarId: String?

    var body: some View {
        VStack(spacing: 0) {
            confirmationDialogSheet

            if isLoading {
                loadingView
            } else {
                scrollViewSection

                textFieldSection
            }
        }
        .navigationTitle(isLoading ? "" : (avatar?.name ?? ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if isLoading {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 100, height: 16)
                        .shimmering()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .foregroundStyle(.accent)
                    .padding(8)
                    .styledButton(action: onEllipsisButtonPressed)
            }
        }
        .showCustomAlert(alert: $alert)
        .showModal(
            isPresented: $showProfileModal,
            content: {
                if let avatar {
                    profileModal(avatar: avatar)
                }
            },
            transition: .slide)
        .task {
            await loadAvatar()
        }
        .task {
            await loadChat()
            await listenForChatMessages()
            await lastMessageSeen()
        }
        .onAppear {
            isUserInThisScreen = true
            loadCurrentUser()
        }
        .onDisappear {
            isUserInThisScreen = false
        }
    }

    private var loadingView: some View {
        VStack(spacing: 0) {
            VStack {
                Spacer()

                VStack(spacing: 20) {
                    skeletonAvatarBubble(width: 220, height: 44)

                    skeletonUserBubble(width: 180, height: 40)

                    skeletonAvatarBubble(width: 250, height: 64)

                    skeletonUserBubble(width: 140, height: 40)

                    skeletonAvatarBubble(width: 200, height: 48)
                }
                .padding([.horizontal, .top], 8)
                .shimmering()
            }
            .padding(.bottom, 20)
            // Text field placeholder
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.gray.opacity(0.15))
                .frame(height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(uiColor: .secondarySystemBackground))
        }
    }

    private func skeletonAvatarBubble(width: CGFloat, height: CGFloat) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            Circle()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 36, height: 36)

            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.25))
                .frame(width: width, height: height)

            Spacer(minLength: 0)
        }
        .padding(.trailing, 40)
    }

    private func skeletonUserBubble(width: CGFloat, height: CGFloat) -> some View {
        HStack {
            Spacer(minLength: 60)
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.3))
                .frame(width: width, height: height)
        }
    }

    private var confirmationDialogSheet: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .confirmationDialog("What would you like to do?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                Button("Report User/Chat", role: .destructive) { }

                Button("Delete Chat", role: .destructive) {
                    onDeleteChatPressed()
                }
            }
    }

    private var scrollViewSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    if chatMessages.isEmpty {
                        emptyChatView
                    } else {
                        ForEach(Array(chatMessages.enumerated()), id: \.element.id) { index, message in
                            if let uid = try? authManager.getAuthId() {
                                if shouldShowTimestamp(for: message, at: index) {
                                    timestampView(date: message.dateCreatedCalculated)
                                }

                                ChatBubbleViewBuilder(
                                    isAvatar: message.authorId != uid,
                                    imageName: avatar?.profileImageName,
                                    message: message,
                                    onImagePressed: self.onImagePressed,
                                    bubbleColor: currentUser?.profileColor ?? .accent
                                )
                                .id(message.id)
                            }
                        }

                        if isAvatarTyping {
                            typingIndicatorView
                        }
                    }
                }
                .padding([.horizontal, .top], 8)
            }
            .defaultScrollAnchor(.bottom)
            .safeAreaPadding(.bottom, 20)
            .animation(.default, value: chatMessages.count)
            .animation(.default, value: isAvatarTyping)
            .onChange(of: scrollPositionId) { _, newId in
                guard let newId else { return }
                withAnimation {
                    proxy.scrollTo(newId, anchor: .bottom)
                }
            }
        }
    }

    private func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(Date.now.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
    }

    private var emptyChatView: some View {
        VStack(spacing: 16) {
            ZStack {
                if let imageName = avatar?.profileImageName, !imageName.isEmpty {
                    ImageLoaderView(imageUrlString: imageName)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.gray)
                                .font(.system(size: 36))
                        )
                }
            }
            .styledButton {
                showProfileModal.toggle()
            }
            .frame(width: 90, height: 90)
            .clipShape(Circle())

            VStack(spacing: 6) {
                Text(avatar?.name ?? "Unknown")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(avatar?.characterDescription ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            Text("Start a conversation!")
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.accentColor, in: Capsule())
                .styledButton(.pressable) {
                    onSendMessagePressed(chatStarter: "Hello \(avatar?.name ?? "")!")
                }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var textFieldSection: some View {
        TextField("Say something...", text: $messageTextField)
            .keyboardType(.alphabet)
            .autocorrectionDisabled(true)
            .padding()
            .padding(.trailing, 40)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(Color(uiColor: .systemBackground))

                    RoundedRectangle(cornerRadius: 100)
                        .stroke(.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .overlay(alignment: .trailing) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .fontWeight(.light)
                    .foregroundStyle(.accent)
                    .padding(.horizontal, 4)
                    .tappableBackground()
                    .styledButton(.plain, action: { onSendMessagePressed() })
                    .disabled(messageTextField.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(uiColor: .secondarySystemBackground))
    }

    private var typingIndicatorView: some View {
        HStack {
            ZStack {
                if let imageName = avatar?.profileImageName, !imageName.isEmpty {
                    ImageLoaderView(imageUrlString: imageName)
                } else {
                    Rectangle().fill(.gray.opacity(0.7))
                }
            }
            .clipShape(Circle())
            .frame(width: 45, height: 45)

            TypingIndicatorView()
                .scaleEffect(0.8)
            Spacer()
        }
        .padding(.trailing, 75)
        .id("typingIndicator")
    }

    private func profileModal(avatar: Avatar) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterDescription,
            onXMarkPressed: self.onXMarkPressed
        )
    }
}

extension ChatView {
    private func onSendMessagePressed(chatStarter: String? = nil) {
        if let chatStarter {
            messageTextField = chatStarter
        }

        guard !messageTextField.isEmpty else { return }

        Task {
            do {
                let uid = try authManager.getAuthId()
                if chat == nil {
                    let newChat = Chat.newChat(userId: uid, avatarId: avatarId ?? "")
                    try await chatManager.createNewChat(chat: newChat)

                    self.chat = newChat

                    Task {
                        await listenForChatMessages()
                    }
                }

                let newMessage = ChatMessage.newMessageFromUser(
                    chatId: chat?.id ?? UUID().uuidString,
                    userId: uid,
                    message: messageTextField
                )
                messageTextField = ""

                scrollPositionId = newMessage.id

                try await chatManager.addChatMessage(message: newMessage)

                avatarsResponse()
            } catch {
                alert = .init(error: error)
            }
        }
    }

    private func loadCurrentUser() {
        self.currentUser = userManager.currentUser
    }

    private func loadAvatar() async {
        guard let avatarId else { return }

        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            self.avatar = avatar

            try await avatarManager.addRecentAvatar(avatar)
        } catch {
            print(error)
        }
    }

    private func avatarsResponse() {
        guard let currentUser else { return }

        Task {
            isAvatarTyping = true
            scrollPositionId = "typingIndicator"

            defer {
                isAvatarTyping = false
                scrollPositionId = chatMessages.last?.id
            }

            try? await Task.sleep(for: .seconds(1.25))
            do {
                if let avatarDescription = avatar?.characterDescription {

                    let conversationContext = chatMessages.dropLast().map { msg in
                        let sender = msg.authorId == currentUser.userId ? "User" : "You"
                        return "\(sender): \(msg.content ?? "")"
                    }.joined(separator: "\n")

                    let content = try await aiManager.generateText(input: """
                    Your name is \(avatar?.name ?? "unknown, you can come up with a name")
                    You are \(avatarDescription).

                    Recent conversation:
                    \(conversationContext)

                    User just said: "\(chatMessages.last?.content ?? "")"

                    Reply as this character. Keep it brief. Be natural and conversational.
                    """)

                    let uid = try authManager.getAuthId()
                    let avatarResponse = ChatMessage.newMessageFromAvatar(
                        chatId: chat?.id ?? "",
                        avatarId: avatarId ?? "",
                        message: content,
                        seenByIds: isUserInThisScreen ? [uid] : []
                    )

                    try await chatManager.addChatMessage(message: avatarResponse)
                }
            } catch {
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func loadChat() async {
        do {
            let uid = try authManager.getAuthId()
            guard let avatarId else { return }

            self.chat = try await chatManager.loadChat(userId: uid, avatarId: avatarId)
            isLoading = false
        } catch {
            alert = AnyAppAlert(error: error)
        }
    }

    private func listenForChatMessages() async {
        do {
            guard let chat else { return }
            let chatId = chat.id

            for try await value in chatManager.streamChatChanges(chatId: chatId) {
                chatMessages = value.sorted(by: { $0.dateCreatedCalculated < $1.dateCreatedCalculated })
                scrollPositionId = chatMessages.last?.id
            }
        } catch {
            print("Failed to listen for chat changes: \(error)")
        }
    }

    private func lastMessageSeen() async {
        guard let lastMessage = chatMessages.last, let uid = userManager.currentUser?.userId, let chatId = chat?.id else { return }

        do {
            try await chatManager.userHasSeenMessage(messageId: lastMessage.id, chatId: chatId, userId: uid)
        } catch {
            print(error)
        }
    }

    private func shouldShowTimestamp(for message: ChatMessage, at index: Int) -> Bool {
        guard index > 0 else { return true }

        let currentMsgDate = message.dateCreatedCalculated
        let prevMsgDate = chatMessages[index - 1].dateCreatedCalculated

        let isDifferentDay = !Calendar.current.isDate(currentMsgDate, inSameDayAs: prevMsgDate)
        let isMoreThan30Minutes = currentMsgDate.timeIntervalSince(prevMsgDate) >= 30 * 60

        return isDifferentDay || isMoreThan30Minutes
    }

    private func onEllipsisButtonPressed() {
        showConfirmationDialog.toggle()
    }

    private func onXMarkPressed() {
        showProfileModal = false
    }

    private func onImagePressed() {
        showProfileModal = true
    }

    private func onDeleteChatPressed() {
        guard let chat else { return }

        Task {
            do {
                try await chatManager.deleteChat(chatId: chat.id)
                dismiss()
            } catch {
                print(error)
            }
        }
    }
}

#Preview("Chat - Default") {
    NavigationStack {
        ChatView(avatarId: Avatar.mock.avatarId)
    }
    .environment(
        ChatManager(
            service: MockChatService(
                chat: .mock,
                messages: ChatMessage.mocks
            )
        )
    )
    .environment(
        AvatarManager(
            services: MockAvatarServices(
                remote: MockAvatarService(delay: 0)
            )
        )
    )
    .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
    .previewEnvironment()
}

#Preview("Chat - Dark Mode") {
    NavigationStack {
        ChatView(avatarId: Avatar.mock.avatarId)
    }
    .environment(
        ChatManager(
            service: MockChatService(
                chat: .mock,
                messages: ChatMessage.mocks
            )
        )
    )
    .environment(
        AvatarManager(
            services: MockAvatarServices(
                remote: MockAvatarService(delay: 0)
            )
        )
    )
    .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
    .previewEnvironment()
    .preferredColorScheme(.dark)
}

#Preview("Chat - Large Text") {
    NavigationStack {
        ChatView(avatarId: Avatar.mock.avatarId)
    }
    .environment(
        ChatManager(
            service: MockChatService(
                chat: .mock,
                messages: ChatMessage.mocks
            )
        )
    )
    .environment(
        AvatarManager(
            services: MockAvatarServices(
                remote: MockAvatarService(delay: 0)
            )
        )
    )
    .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
    .environment(\.dynamicTypeSize, .accessibility2)
    .previewEnvironment()
}

#Preview("Chat - Loading State") {
    NavigationStack {
        ChatView(avatarId: Avatar.mock.avatarId)
    }
    .environment(
        ChatManager(
            service: MockChatService(
                delay: 2,
                chat: .mock,
                messages: ChatMessage.mocks
            )
        )
    )
    .environment(
        AvatarManager(
            services: MockAvatarServices(
                remote: MockAvatarService(delay: 2)
            )
        )
    )
    .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
    .previewEnvironment()
}

#Preview("Chat - Long Conversation") {
    let messages: [ChatMessage] = [
        .newMessageFromAvatar(
            chatId: Chat.mock.id,
            avatarId: Avatar.mock.avatarId,
            message: "Hey, what are you working on today?",
            seenByIds: [UserModel.mock.userId],
            dateCreated: .distantPast
        ),
        .newMessageFromUser(
            chatId: Chat.mock.id,
            userId: UserModel.mock.userId,
            message: "I am improving the chat screen previews.",
            dateCreated: .now.addingTimeInterval(minutes: -50)
        ),
        .newMessageFromAvatar(
            chatId: Chat.mock.id,
            avatarId: Avatar.mock.avatarId,
            message: "Nice. Are you testing empty, loading, and long conversations?",
            seenByIds: [UserModel.mock.userId],
            dateCreated: .now.addingTimeInterval(minutes: -30)
        ),
        .newMessageFromUser(
            chatId: Chat.mock.id,
            userId: UserModel.mock.userId,
            message: "Yes, I want one preview with more than six messages.",
            dateCreated: .now.addingTimeInterval(minutes: -30)
        ),
        .newMessageFromAvatar(
            chatId: Chat.mock.id,
            avatarId: Avatar.mock.avatarId,
            message: "That is useful because it shows scrolling, spacing, timestamps, and bubble alignment.",
            seenByIds: [UserModel.mock.userId],
            dateCreated: .now.addingTimeInterval(minutes: -30)
        ),
        .newMessageFromUser(
            chatId: Chat.mock.id,
            userId: UserModel.mock.userId,
            message: "Exactly. I also want to see how long text wraps inside the bubble.",
            dateCreated: .now.addingTimeInterval(minutes: -30)
        ),
        .newMessageFromAvatar(
            chatId: Chat.mock.id,
            avatarId: Avatar.mock.avatarId,
            message: "Then add a slightly longer message to make sure the design still feels clean on smaller screens.",
            seenByIds: [UserModel.mock.userId]
        ),
        .newMessageFromUser(
            chatId: Chat.mock.id,
            userId: UserModel.mock.userId,
            message: "Perfect. This preview should help me polish the UI faster."
        )
    ]

    NavigationStack {
        ChatView(avatarId: Avatar.mock.avatarId)
    }
    .environment(
        ChatManager(
            service: MockChatService(
                chat: .mock,
                messages: messages
            )
        )
    )
    .environment(
        AvatarManager(
            services: MockAvatarServices(
                remote: MockAvatarService(delay: 0)
            )
        )
    )
    .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
    .previewEnvironment()
}
