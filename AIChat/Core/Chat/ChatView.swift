//
//  ChatView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

struct ChatView: View {
    @Environment(AIManager.self) private var aiManager
    @Environment(AvatarManager.self) private var avatarManager
    @State private var chatMessages: [ChatMessage] = ChatMessage.mocks
    @State private var avatar: Avatar?
    @State private var currentUser: UserModel? = UserModel.mocks[0]
    @State private var messageTextField: String = ""
    @State private var showConfirmationDialog: Bool = false
    @State private var scrollPositionId: String?
    @State private var showProfileModal: Bool = false
    @State private var isAvatarTyping: Bool = false
    @State private var alert: AnyAppAlert?

    var avatarId: String?

    var body: some View {
        VStack(spacing: 0) {
            confirmationDialogSheet

            scrollViewSection

            textFieldSection
        }
        .task {
            await loadAvatar()
        }
        .navigationTitle(avatar?.name ?? "Unknown")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    ChatBubbleViewBuilder(
                        /// if messageAuthor not the user then it is the avatar
                        isAvatar: message.authorId != currentUser?.userId,
                        imageName: avatar?.profileImageName,
                        message: message,
                        onImagePressed: self.onImagePressed,
                    )
                    .id(message.id)
                }

                if isAvatarTyping {
                    typingIndicatorView
                }
            }
            .padding([.horizontal, .top], 8)
        }
        .defaultScrollAnchor(.bottom)
        .safeAreaPadding(.bottom, 20)
        .scrollPosition(id: $scrollPositionId, anchor: .center) /// When scrollPositionId is set to any message.id then it will scroll to it
        .animation(.default, value: chatMessages.count)
        .animation(.default, value: isAvatarTyping)
    }

    private var textFieldSection: some View {
        TextField("Say something...", text: $messageTextField)
            .keyboardType(.alphabet)
            .autocorrectionDisabled(true)
            .padding()
            .padding(.trailing, 40)
            .background( /// not overlay because overlay will be on top of the text
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
                    .styledButton(.plain, action: onSendMessagePressed)
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
    private func onSendMessagePressed() {
        guard let currentUser else { return }
        guard !messageTextField.isEmpty else { return }

        let newMessage = ChatMessage(
            id: UUID().uuidString,
            chatId: "1",
            authorId: currentUser.userId,
            content: messageTextField,
            seenByIds: nil,
            dateCreated: Date()
        )

        chatMessages.append(newMessage)
        scrollPositionId = newMessage.id

        avatarsResponse()
        messageTextField = ""
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

                    Reply as this character. Keep it brief (1-2 sentences max). Be natural and conversational.
                    """)

                    let avatarResponse = ChatMessage(
                        id: UUID().uuidString,
                        chatId: "1",
                        authorId: avatar?.avatarId ?? "av1",
                        content: content,
                        seenByIds: nil,
                        dateCreated: Date()
                    )
                    chatMessages.append(avatarResponse)
                    scrollPositionId = avatarResponse.id
                }
            } catch {
                alert = AnyAppAlert(error: error)
            }

            isAvatarTyping = false
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
        .previewEnvironment()
}
