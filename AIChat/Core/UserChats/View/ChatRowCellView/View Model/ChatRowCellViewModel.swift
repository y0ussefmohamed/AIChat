//
//  ChatRowCellViewModel.swift
//  AIChat
//

import Foundation

@Observable
@MainActor
class ChatRowCellViewModel {
    private let interactor: ChatRowCellInteractor

    private let chatId: String
    private let avatarId: String

    private(set) var avatar: Avatar?
    private(set) var lastChatMessage: ChatMessage?
    private var didLoadAvatar = false
    private var didLoadChatMessage = false

    var isLoading: Bool {
        !didLoadAvatar || !didLoadChatMessage
    }

    var isNewMessage: Bool {
        guard !isLoading else { return false }
        guard let lastChatMessage, let currentUserId = interactor.currentUser?.userId else { return true }
        return !lastChatMessage.isSeenBy(userId: currentUserId)
    }

    var headline: String? {
        isLoading ? ".... ...." : avatar?.name
    }

    var subheadline: String? {
        if isLoading {
            return ".... .... .... ...."
        }
        if avatar == nil && lastChatMessage == nil {
            return "Error"
        }
        return lastChatMessage?.content
    }

    init(interactor: ChatRowCellInteractor, chatId: String, avatarId: String) {
        self.interactor = interactor
        self.chatId = chatId
        self.avatarId = avatarId
    }

    func loadAvatar() async {
        do {
            let avatar = try await interactor.getAvatar(id: avatarId)
            guard !Task.isCancelled else { return }
            self.avatar = avatar
        } catch {
            guard !Task.isCancelled else { return }
            interactor.trackEvent(event: ChatRowCellViewEvent.loadAvatarFail(error: error))
        }
        didLoadAvatar = true
    }

    func streamLastMessage() async {
        do {
            for try await messages in interactor.streamChatChanges(chatId: chatId) {
                guard !Task.isCancelled else { return }
                lastChatMessage = messages.sorted {
                    $0.dateCreatedCalculated < $1.dateCreatedCalculated
                }.last
                didLoadChatMessage = true
            }
        } catch {
            guard !Task.isCancelled else { return }
            interactor.trackEvent(event: ChatRowCellViewEvent.streamLastMessageFail(error: error))
        }
        guard !Task.isCancelled else { return }
        didLoadChatMessage = true
    }
}

// MARK: - Events

extension ChatRowCellViewModel {
    enum ChatRowCellViewEvent: LoggableEvent {
        case loadAvatarFail(error: Error)
        case streamLastMessageFail(error: Error)

        var eventName: String {
            switch self {
            case .loadAvatarFail:
                return "UserChatsView_LoadCellAvatar_Fail"
            case .streamLastMessageFail:
                return "UserChatsView_StreamLastMessage_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(let error), .streamLastMessageFail(let error):
                return error.asEventParameter
            }
        }

        var type: LogType { .severe }
    }
}
