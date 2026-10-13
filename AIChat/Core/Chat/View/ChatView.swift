//
//  ChatView.swift
//  AIChat
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            confirmationDialogSheet

            if viewModel.isLoading {
                loadingView
            } else {
                scrollViewSection

                textFieldSection
            }
        }
        .navigationTitle(viewModel.isLoading ? "" : (viewModel.avatar?.name ?? ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if viewModel.isLoading {
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
                    .styledButton(action: viewModel.onEllipsisButtonPressed)
                    .accessibilityLabel("Conversation actions")
                    .accessibilityIdentifier(AccessibilityID.Chat.actions)
            }
        }
        .screenAppearAnalytics(viewName: "ChatView")
        .showCustomAlert(alert: $viewModel.alert)
        .showModal(
            isPresented: $viewModel.showProfileModal) {
                if let avatar = viewModel.avatar {
                    profileModal(avatar: avatar)
                }
            }

        .task {
            await viewModel.loadData()
        }
        .task(id: viewModel.chat?.id) {
            await viewModel.listenForChatMessages()
        }
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
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
            .confirmationDialog("What would you like to do?", isPresented: $viewModel.showConfirmationDialog, titleVisibility: .visible) {
                Button("Report User/Chat", role: .destructive) {
                    viewModel.onReportChatPressed()
                }
                .disabled(viewModel.chat == nil)

                Button("Delete Chat", role: .destructive) {
                    viewModel.onDeleteChatPressed(onDismiss: { dismiss() })
                }
                .disabled(viewModel.isSendingMessage)
            }
    }

    private var scrollViewSection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.chatMessages.isEmpty {
                        emptyChatView
                    } else {
                        ForEach(Array(viewModel.chatMessages.enumerated()), id: \.element.id) { index, message in
                            if let uid = viewModel.currentUserId {
                                if viewModel.shouldShowTimestamp(for: message, at: index) {
                                    timestampView(date: message.dateCreatedCalculated)
                                        .accessibilityIdentifier(AccessibilityID.Chat.timestamp(message.id))
                                }

                                ChatBubbleViewBuilder(
                                    isAvatar: message.authorId != uid,
                                    imageName: viewModel.avatar?.profileImageName,
                                    message: message,
                                    onImagePressed: viewModel.onImagePressed,
                                    bubbleColor: viewModel.currentUser?.profileColor ?? .accent
                                )
                                .id(message.id)
                            }
                        }

                        if viewModel.isAvatarTyping {
                            typingIndicatorView
                        }
                    }
                }
                .padding([.horizontal, .top], 8)
            }
            .accessibilityIdentifier(AccessibilityID.Chat.scroll)
            .defaultScrollAnchor(.bottom)
            .safeAreaPadding(.bottom, 20)
            .animation(.default, value: viewModel.chatMessages.count)
            .animation(.default, value: viewModel.isAvatarTyping)
            .onChange(of: viewModel.scrollPositionId) { _, newId in
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
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
    }

    private var emptyChatView: some View {
        VStack(spacing: 16) {
            ZStack {
                if let imageName = viewModel.avatar?.profileImageName, !imageName.isEmpty {
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
                viewModel.onImagePressed()
            }
            .accessibilityLabel("View avatar profile")
            .accessibilityIdentifier(AccessibilityID.Chat.emptyAvatar)
            .frame(width: 90, height: 90)
            .clipShape(Circle())

            VStack(spacing: 6) {
                Text(viewModel.avatar?.name ?? "Unknown")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(viewModel.avatar?.characterDescription ?? "")
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
                    viewModel.onSendMessagePressed(chatStarter: "Hello \(viewModel.avatar?.name ?? "")!")
                }
                .accessibilityIdentifier(AccessibilityID.Chat.starter)
                .disabled(!viewModel.canSendMessage)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var textFieldSection: some View {
        TextField("Say something...", text: $viewModel.messageTextField)
            .accessibilityIdentifier(AccessibilityID.Chat.composer)
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
                    .styledButton(.plain, action: { viewModel.onSendMessagePressed() })
                    .accessibilityLabel("Send message")
                    .accessibilityIdentifier(AccessibilityID.Chat.send)
                    .disabled(!viewModel.canSendMessage || viewModel.messageTextField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(uiColor: .secondarySystemBackground))
    }

    private var typingIndicatorView: some View {
        HStack {
            ZStack {
                if let imageName = viewModel.avatar?.profileImageName, !imageName.isEmpty {
                    ImageLoaderView(imageUrlString: imageName)
                } else {
                    Rectangle().fill(.gray.opacity(0.7))
                }
            }
            .clipShape(Circle())
            .frame(width: 45, height: 45)

            TypingIndicatorView()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Avatar is typing")
                .accessibilityIdentifier(AccessibilityID.Chat.typing)
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
            onXMarkPressed: viewModel.onXMarkPressed
        )
    }
}

// MARK: - Previews

@MainActor
private func makeChatPreviewContainer(delay: Double = 0, messages: [ChatMessage]? = nil) -> DependencyContainer {
    let container = DevPreview.shared.container
    let auth = UserAuthInfo.mock()
    let avatar = Avatar.mock
    let chat = Chat.newChat(userId: auth.uid, avatarId: avatar.avatarId)
    let sourceMessages = messages ?? ChatMessage.mocks
    let previewMessages = sourceMessages.enumerated().map { index, message in
        let isUser = messages == nil ? index.isMultiple(of: 2) : message.authorId == UserModel.mock.userId
        return ChatMessage(
            id: message.id,
            chatId: chat.id,
            authorId: isUser ? auth.uid : avatar.avatarId,
            content: message.content,
            seenByIds: [auth.uid],
            dateCreated: message.dateCreated
        )
    }
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: auth)))
    container.register(UserManager.self, service: UserManager(services: MockUserServicesContainer(user: UserModel(auth: auth, creationVersion: nil))))
    container.register(ChatManager.self, service: ChatManager(
        service: MockChatService(delay: delay, chat: chat, messages: previewMessages)
    ))
    container.register(AvatarManager.self, service: AvatarManager(
        services: MockAvatarServices(remote: MockAvatarService(delay: 0))
    ))
    return container
}

#Preview("Chat - Default") {
    let container = makeChatPreviewContainer()
    return NavigationStack {
        ChatView(viewModel: ChatViewModel(interactor: CoreInteractor(container: container), avatarId: Avatar.mock.avatarId))
    }
    .previewEnvironment()
    .environment(container)
}

#Preview("Chat - Dark Mode") {
    let container = makeChatPreviewContainer()
    return NavigationStack {
        ChatView(viewModel: ChatViewModel(interactor: CoreInteractor(container: container), avatarId: Avatar.mock.avatarId))
    }
    .previewEnvironment()
    .environment(container)
    .preferredColorScheme(.dark)
}

#Preview("Chat - Large Text") {
    let container = makeChatPreviewContainer()
    return NavigationStack {
        ChatView(viewModel: ChatViewModel(interactor: CoreInteractor(container: container), avatarId: Avatar.mock.avatarId))
    }
    .previewEnvironment()
    .environment(container)
    .environment(\.dynamicTypeSize, .accessibility2)
}

#Preview("Chat - Loading State") {
    let container = makeChatPreviewContainer(delay: 2)
    return NavigationStack {
        ChatView(viewModel: ChatViewModel(interactor: CoreInteractor(container: container), avatarId: Avatar.mock.avatarId))
    }
    .previewEnvironment()
    .environment(container)
}

#Preview("Chat - Long Conversation") {
    let container = makeChatPreviewContainer(messages: ChatMessage.previewLongConversation())
    return NavigationStack {
        ChatView(viewModel: ChatViewModel(interactor: CoreInteractor(container: container), avatarId: Avatar.mock.avatarId))
    }
    .previewEnvironment()
    .environment(container)
}
