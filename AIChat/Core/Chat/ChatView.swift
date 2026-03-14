//
//  ChatView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

struct ChatView: View {
    var avatarId: String = Avatar.mock.avatarId /// to fetch avatar onAppear {}

    @State private var chatMessages: [ChatMessage] = ChatMessage.mocks
    @State private var avatar: Avatar? = .mock
    @State private var currentUser: User? = .mock
    @State private var messageTextField: String = ""
    @State private var showConfirmationDialog: Bool = false
    @State private var scrollPositionId: String?
    @State private var showProfileModal: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            confirmationDialogSheet

            scrollViewSection

            textFieldSection
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
                        onImagePressed: self.onImagePressed
                    )
                    .id(message.id)
                }
            }
            .padding([.horizontal, .top], 8)
        }
        .defaultScrollAnchor(.bottom)
        .safeAreaPadding(.bottom, 20)
        .scrollPosition(id: $scrollPositionId, anchor: .center) /// When scrollPositionId is set to any message.id then it will scroll to it
        .animation(.default, value: chatMessages.count)
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

    private func profileModal(avatar: Avatar) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue,
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

        messageTextField = ""
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

#Preview {
    NavigationStack {
        ChatView()
    }
}
