//
//  UserChatsViewModel.swift
//  AIChat
//

import Foundation

@MainActor
@Observable
class UserChatsViewModel {
    private let interactor: UserChatsInteractor

    private(set) var chats: [Chat] = []
    private(set) var recentAvatars: [Avatar] = []
    private(set) var isLoading: Bool = true

    var navPathStack: [String] = []

    var currentUserId: String? {
        interactor.currentUser?.userId
    }

    init(interactor: UserChatsInteractor) {
        self.interactor = interactor
    }

    func loadData() async {
        await loadChats()
        await loadRecentsAvatars()
        isLoading = false
    }

    private func loadRecentsAvatars() async {
        interactor.trackEvent(event: UserChatsViewEvent.loadRecentsStart)
        do {
            recentAvatars = try interactor.getRecentAvatars()
            interactor.trackEvent(event: UserChatsViewEvent.loadRecentsSuccess(count: recentAvatars.count))
        } catch {
            interactor.trackEvent(event: UserChatsViewEvent.loadRecentsFail(error: error))
        }
    }

    private func loadChats() async {
        interactor.trackEvent(event: UserChatsViewEvent.loadChatsStart)
        do {
            if let uid = currentUserId {
                chats = try await interactor.loadChats(userId: uid)
                chats.sort(by: { $0.dateModified > $1.dateModified })
                interactor.trackEvent(event: UserChatsViewEvent.loadChatsSuccess(count: chats.count))
            }
        } catch {
            interactor.trackEvent(event: UserChatsViewEvent.loadChatsFail(error: error))
        }
    }

    func getAvatarForCell(_ avatarId: String) async -> Avatar? {
        do {
            return try await interactor.getAvatar(id: avatarId)
        } catch {
            interactor.trackEvent(event: UserChatsViewEvent.loadCellAvatarFail(error: error))
        }
        return nil
    }

    /// Continuously streams chat changes and calls `onUpdate` every time a new value is emitted.
    /// This keeps the cell in sync with the latest message and seen status in real time.
    func streamLastMessageForCell(chatId: String, onUpdate: @escaping @MainActor (ChatMessage?) -> Void) async {
        do {
            for try await value in interactor.streamChatChanges(chatId: chatId) {
                let messages = value.sorted(by: { $0.dateCreatedCalculated < $1.dateCreatedCalculated })
                onUpdate(messages.last)
            }
        } catch {
            interactor.trackEvent(event: UserChatsViewEvent.streamLastMessageFail(error: error))
        }
    }

    func onRowTap(for chat: Chat) {
        interactor.trackEvent(event: UserChatsViewEvent.chatRowPressed(chat: chat))
        navPathStack.append(chat.avatarId)
    }

    func onRecentsAvatarTap(avatarId: String) {
        interactor.trackEvent(event: UserChatsViewEvent.recentAvatarPressed(avatarId: avatarId))
        navPathStack.append(avatarId)
    }

    func onExploreAvatarsPressed() {
        interactor.trackEvent(event: UserChatsViewEvent.exploreAvatarsPressed)
    }
}

// MARK: - Events

extension UserChatsViewModel {
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
                return avatarId.asEventParameter(key: "avatar_id")

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
