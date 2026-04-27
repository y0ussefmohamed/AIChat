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
                    ProgressView()
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
            ScrollView {
                VStack(spacing: 20) {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 90, height: 90)
                        .padding(.top, 80)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 120, height: 16)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 200, height: 12)
                }
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
    }

    private var confirmationDialogSheet: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .confirmationDialog("What would you like to do?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
                Button("Report User/Chat", role: .destructive) { }

                Button("Delete Chat", role: .destructive) {
                    chatMessages.removeAll()
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
                        ForEach(chatMessages) { message in
                            if let uid = try? authManager.getAuthId() {
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

    private func onEllipsisButtonPressed() {
        showConfirmationDialog.toggle()
    }

    private func onXMarkPressed() {
        showProfileModal = false
    }

    private func onImagePressed() {
        showProfileModal = true
    }
}

private struct PreviewView: View {
    var body: some View {
        NavigationStack {
            ChatView(avatarId: "av1")
                .onAppear {
                    // This will trigger loadAvatar to fetch the mock
                }
        }
    }
}


#Preview {
    PreviewView()
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 0))))
        .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
        .previewEnvironment()
}
