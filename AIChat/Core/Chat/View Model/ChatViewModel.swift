//
//  ChatViewModel.swift
//  AIChat
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

@MainActor
@Observable
class ChatViewModel {
    // Dependencies and fixed inputs
    private let interactor: ChatInteractor
    private let avatarId: String

    // Internal state
    private var hasLoadedChat = false
    private var hasLoadedMessages = false
    private var isUserInThisScreen = false

    // State the view can read, but only the view model can change
    private(set) var chat: Chat?
    private(set) var chatMessages: [ChatMessage] = []
    private(set) var avatar: Avatar?
    private(set) var isLoading = true
    private(set) var isSendingMessage = false
    private(set) var isAvatarTyping = false

    private(set) var scrollPositionId: String?

    // State the view can read and change through bindings
    var messageTextField = ""
    var showConfirmationDialog = false
    var showProfileModal = false

    var alert: AnyAppAlert?

    // Computed values
    var currentUser: UserModel? {
        interactor.currentUser
    }

    var currentUserId: String? {
        try? interactor.getAuthId()
    }

    var canSendMessage: Bool {
        !isLoading && hasLoadedChat && hasLoadedMessages && avatar != nil && !isSendingMessage && !isAvatarTyping
    }

    init(interactor: ChatInteractor, avatarId: String) {
        self.interactor = interactor
        self.avatarId = avatarId
    }

    func loadData() async {
        isLoading = true
        hasLoadedChat = false
        defer { isLoading = false }

        await loadAvatar()
        guard !Task.isCancelled else { return }
        await loadChat()
    }

    func onAppear() {
        isUserInThisScreen = true
    }

    func onDisappear() {
        isUserInThisScreen = false
    }

    func onSendMessagePressed(chatStarter: String? = nil) {
        guard canSendMessage else { return }
        let messageText = chatStarter ?? messageTextField
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isSendingMessage = true
        interactor.trackEvent(event: ChatViewEvent.sentChatMessageStart(chat: chat, Avatar: avatar))

        Task {
            defer { isSendingMessage = false }
            do {
                let uid = try interactor.getAuthId()
                if chat == nil {
                    let newChat = Chat.newChat(userId: uid, avatarId: avatarId)
                    try await createNewChat(chat: newChat)
                    chat = newChat
                }
                guard let chat else { return }

                let newMessage = ChatMessage.newMessageFromUser(chatId: chat.id, userId: uid, message: messageText)
                try await interactor.addChatMessage(message: newMessage)
                if messageTextField == messageText {
                    messageTextField = ""
                }
                appendMessageIfNeeded(newMessage)
                interactor.trackEvent(event: ChatViewEvent.messageSentSuccess(avatar: avatar, message: newMessage))

                await avatarsResponse(to: newMessage, in: chat)
            } catch {
                interactor.trackEvent(event: ChatViewEvent.sentChatMessageFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }

    func onReportChatPressed() {
        guard let chat else { return }
        interactor.trackEvent(event: ChatViewEvent.reportChatStart(chat: chat, avatar: avatar))
        Task {
            do {
                let uid = try interactor.getAuthId()
                try await interactor.reportChat(chatId: chat.id, userId: uid)
                interactor.trackEvent(event: ChatViewEvent.reportChatSuccess)
                alert = AnyAppAlert(
                    title: "Report Submitted",
                    subtitle: "Thank you for letting us know. Our team will review this conversation."
                )
            } catch {
                interactor.trackEvent(event: ChatViewEvent.reportChatFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func loadAvatar() async {
        interactor.trackEvent(event: ChatViewEvent.loadAvatarStart)
        do {
            let avatar = try await interactor.getAvatar(id: avatarId)
            guard !Task.isCancelled else { return }
            self.avatar = avatar
            interactor.trackEvent(event: ChatViewEvent.loadAvatarSuccess(avatar: avatar))
            try await interactor.addRecentAvatar(avatar)
        } catch {
            guard !Task.isCancelled else { return }
            interactor.trackEvent(event: ChatViewEvent.loadAvatarFail(error: error))
            alert = AnyAppAlert(error: error)
        }
    }

    private func avatarsResponse(to message: ChatMessage, in chat: Chat) async {
        guard let avatar else { return }
        interactor.trackEvent(event: ChatViewEvent.avatarResponseStart)
        isAvatarTyping = true
        scrollPositionId = "typingIndicator"
        defer {
            isAvatarTyping = false
            scrollPositionId = chatMessages.last?.id
        }

        do {
            try await Task.sleep(for: .seconds(1.25))
            let content = try await interactor.generateText(input: responsePrompt(for: message, avatar: avatar))
            let uid = try interactor.getAuthId()
            let response = ChatMessage.newMessageFromAvatar(
                chatId: chat.id,
                avatarId: avatarId,
                message: content,
                seenByIds: isUserInThisScreen ? [uid] : []
            )
            interactor.trackEvent(event: ChatViewEvent.avatarResponseGenerated(chat: chat, avatar: avatar, response: response))
            try await interactor.addChatMessage(message: response)
            appendMessageIfNeeded(response)
            interactor.trackEvent(event: ChatViewEvent.responseSavedSuccess)
        } catch {
            guard !Task.isCancelled else { return }
            interactor.trackEvent(event: ChatViewEvent.avatarResponseFail(error: error))
            alert = AnyAppAlert(error: error)
        }
    }

    private func responsePrompt(for message: ChatMessage, avatar: Avatar) -> String {
        let date = Date()
        let conversationContext = chatMessages.filter { $0.id != message.id }.map { previousMessage in
            let sender = previousMessage.authorId == message.authorId ? "User" : "You"
            return "\(sender): \(previousMessage.content ?? "")"
        }.joined(separator: "\n")
        return """
        Your name is \(avatar.name ?? "unknown, you can come up with a name")
        You are \(avatar.characterDescription ?? "an AI chat companion").

        Recent conversation:
        \(conversationContext)

        User just said: "\(message.content ?? "")"

        Time is now \(date.formatted(date: .abbreviated, time: .omitted)) • \(date.formatted(date: .omitted, time: .shortened))

        Reply as this character. Keep it brief. Be natural and conversational.
        """
    }

    private func appendMessageIfNeeded(_ message: ChatMessage) {
        if !chatMessages.contains(where: { $0.id == message.id }) {
            chatMessages.append(message)
            chatMessages.sort { $0.dateCreatedCalculated < $1.dateCreatedCalculated }
        }
        scrollPositionId = message.id
    }

    private func createNewChat(chat: Chat) async throws {
        interactor.trackEvent(event: ChatViewEvent.createChatStart(chat: chat))
        do {
            try await interactor.createNewChat(chat: chat)
            interactor.trackEvent(event: ChatViewEvent.createChatSuccess(chat: chat))
        } catch {
            interactor.trackEvent(event: ChatViewEvent.createChatFail(error: error))
            throw error
        }
    }

    private func loadChat() async {
        interactor.trackEvent(event: ChatViewEvent.loadChatStart)
        do {
            let uid = try interactor.getAuthId()
            let loadedChat = try await interactor.loadChat(userId: uid, avatarId: avatarId)
            guard !Task.isCancelled else { return }
            if loadedChat?.id != chat?.id {
                chatMessages = []
                hasLoadedMessages = false
            }
            chat = loadedChat
            hasLoadedChat = true
            if loadedChat == nil {
                hasLoadedMessages = true
            }
            interactor.trackEvent(event: ChatViewEvent.loadChatSuccess(chat: chat))
        } catch {
            guard !Task.isCancelled else { return }
            interactor.trackEvent(event: ChatViewEvent.loadChatFail(error: error))
            alert = AnyAppAlert(error: error)
        }
    }

    func listenForChatMessages() async {
        guard let chat else { return }
        interactor.trackEvent(event: ChatViewEvent.loadMessagesStart)
        do {
            for try await value in interactor.streamChatChanges(chatId: chat.id) {
                guard !Task.isCancelled else { return }
                chatMessages = value.sorted { $0.dateCreatedCalculated < $1.dateCreatedCalculated }
                hasLoadedMessages = true
                if !isAvatarTyping {
                    scrollPositionId = chatMessages.last?.id
                }
                if isUserInThisScreen {
                    await lastMessageSeen()
                }
            }
            guard !Task.isCancelled else { return }
            hasLoadedMessages = true
        } catch {
            guard !Task.isCancelled else { return }
            interactor.trackEvent(event: ChatViewEvent.loadMessagesFail(error: error))
            alert = AnyAppAlert(error: error)
        }
    }

    private func lastMessageSeen() async {
        guard let lastMessage = chatMessages.last,
              let uid = currentUserId,
              let chatId = chat?.id,
              !lastMessage.isSeenBy(userId: uid) else { return }
        do {
            try await interactor.userHasSeenMessage(messageId: lastMessage.id, chatId: chatId, userId: uid)
        } catch {
            guard !Task.isCancelled else { return }
            interactor.trackEvent(event: ChatViewEvent.messageSeenFail(error: error))
        }
    }

    func shouldShowTimestamp(for message: ChatMessage, at index: Int) -> Bool {
        guard index > 0, chatMessages.indices.contains(index - 1) else { return true }
        let currentDate = message.dateCreatedCalculated
        let previousDate = chatMessages[index - 1].dateCreatedCalculated
        return !Calendar.current.isDate(currentDate, inSameDayAs: previousDate)
            || currentDate.timeIntervalSince(previousDate) >= 30 * 60
    }

    func onEllipsisButtonPressed() {
        showConfirmationDialog.toggle()
    }

    func onXMarkPressed() {
        showProfileModal = false
    }

    func onImagePressed() {
        showProfileModal = true
    }

    func onDeleteChatPressed(onDismiss: @escaping () -> Void) {
        guard let chat, !isSendingMessage else { return }
        interactor.trackEvent(event: ChatViewEvent.deleteChatStart(chat: chat))
        Task {
            do {
                try await interactor.deleteChat(chatId: chat.id)
                interactor.trackEvent(event: ChatViewEvent.deleteChatSuccess)
                onDismiss()
            } catch {
                interactor.trackEvent(event: ChatViewEvent.deleteChatFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }
}


extension ChatViewModel {
    enum ChatViewEvent: LoggableEvent {
        case loadAvatarStart, loadAvatarSuccess(avatar: Avatar?), loadAvatarFail(error: Error)
        case loadChatStart, loadChatSuccess(chat: Chat?), loadChatFail(error: Error)
        case createChatStart(chat: Chat?), createChatSuccess(chat: Chat?), createChatFail(error: Error)
        case loadMessagesStart, loadMessagesFail(error: Error)
        case messageSeenFail(error: Error)
        case sentChatMessageStart(chat: Chat?, Avatar: Avatar?), sentChatMessageFail(error: Error)
        case messageSentSuccess(avatar: Avatar?, message: ChatMessage?)
        case avatarResponseStart, avatarResponseFail(error: Error)
        case avatarResponseGenerated(chat: Chat?, avatar: Avatar?, response: ChatMessage)
        case responseSavedSuccess
        case deleteChatStart(chat: Chat?), deleteChatSuccess, deleteChatFail(error: Error)
        case reportChatStart(chat: Chat?, avatar: Avatar?), reportChatSuccess, reportChatFail(error: Error)

        var eventName: String {
            switch self {
            case .loadAvatarStart:
                return "ChatView_LoadAvatar_Start"
            case .loadAvatarSuccess:
                return "ChatView_LoadAvatar_Success"
            case .loadAvatarFail:
                return "ChatView_LoadAvatar_Fail"
            case .loadChatStart:
                return "ChatView_LoadChat_Start"
            case .loadChatSuccess:
                return "ChatView_LoadChat_Success"
            case .loadChatFail:
                return "ChatView_LoadChat_Fail"
            case .createChatStart:
                return "ChatView_CreateChat_Start"
            case .createChatSuccess:
                return "ChatView_CreateChat_Success"
            case .createChatFail:
                return "ChatView_CreateChat_Fail"
            case .loadMessagesStart:
                return "ChatView_LoadMessages_Start"
            case .loadMessagesFail:
                return "ChatView_LoadMessages_Fail"
            case .messageSeenFail:
                return "ChatView_MessageSeen_Fail"
            case .sentChatMessageStart:
                return "ChatView_MessageSent_Start"
            case .sentChatMessageFail:
                return "ChatView_MessageSent_Fail"
            case .messageSentSuccess:
                return "ChatView_MessageSent_Success"
            case .avatarResponseStart:
                return "ChatView_AvatarResponse_Start"
            case .avatarResponseFail:
                return "ChatView_AvatarResponse_Fail"
            case .avatarResponseGenerated:
                return "ChatView_AvatarResponse_Generated"
            case .responseSavedSuccess:
                return "ChatView_ResponseSaved_Success"
            case .deleteChatStart:
                return "ChatView_DeleteChat_Start"
            case .deleteChatSuccess:
                return "ChatView_DeleteChat_Success"
            case .deleteChatFail:
                return "ChatView_DeleteChat_Fail"
            case .reportChatStart:
                return "ChatView_ReportChat_Start"
            case .reportChatSuccess:
                return "ChatView_ReportChat_Success"
            case .reportChatFail:
                return "ChatView_ReportChat_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarSuccess(avatar: let avatar):
                return avatar?.asEventParameter

            case .loadAvatarFail(error: let error),
                 .loadChatFail(error: let error),
                 .createChatFail(error: let error),
                 .loadMessagesFail(error: let error),
                 .messageSeenFail(error: let error),
                 .sentChatMessageFail(error: let error),
                 .avatarResponseFail(error: let error),
                 .deleteChatFail(error: let error),
                 .reportChatFail(error: let error):
                return error.asEventParameter

            case .messageSentSuccess(avatar: let avatar, message: let message):
                if let avatar, let message {
                    return avatar.asEventParameter.merged(message.asEventParameter)
                } else {
                    return nil
                }

            case .loadChatSuccess(chat: let chat),
                 .createChatStart(chat: let chat),
                 .createChatSuccess(chat: let chat),
                 .deleteChatStart(chat: let chat):
                return chat?.asEventParameter

            case .sentChatMessageStart(chat: let chat, Avatar: let avatar),
                 .reportChatStart(chat: let chat, avatar: let avatar):
                return (chat?.asEventParameter ?? [:])
                    .merged(avatar?.asEventParameter)

            case .avatarResponseGenerated(chat: let chat, avatar: let avatar, response: let response):
                return (avatar?.asEventParameter ?? [:])
                    .merged(chat?.asEventParameter)
                    .merged(response.asEventParameter)

            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadAvatarFail, .loadMessagesFail, .messageSeenFail, .avatarResponseFail:
                return .severe
            case .loadChatFail, .createChatFail, .sentChatMessageFail, .deleteChatFail, .reportChatFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
}
