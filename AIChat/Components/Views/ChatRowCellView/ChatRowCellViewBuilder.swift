//
//  ChatRowCellViewBuilder.swift
//  AIChat
//
//  Created by Youssef Mohamed on 10/03/2026.
//

import SwiftUI

/// What problem does this solve?
/// When we do a loop on chats, each chat has some details we want to fetch those details to build the UI, but we can't use .task{} for each item in the loop and if we put those items that we want to fetch in the Model struct itself so we don't have to fetch, it won't be a scalable/generic solution

/// This is a wrapper over the `ChatRowCellView` in order to fetch data asynchronsly, related to where this view is used
struct ChatRowCellViewBuilder: View {

    var currentUserId: String? = ""
    var chat: Chat = .mock

    @State private var avatar: Avatar?
    @State private var lastChatMessage: ChatMessage?

    var getAvatar: () async -> Avatar?
    var getLastChatMessage: () async -> ChatMessage?

    @State private var didLoadAvatar: Bool = false
    @State private var didLoadChatMessage: Bool = false

    private var isLoading: Bool {
        didLoadAvatar && didLoadChatMessage ? false : true
    }

    private var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId else { return false }

        return lastChatMessage.isSeenBy(userId: currentUserId)
    }

    private var headline: String? {
        isLoading ? ".... ...." : avatar?.name
    }

    private var subheadline: String? {
        if isLoading {
            return ".... .... .... ...."
        }

        /// finished loading, returned nil
        if avatar == nil && lastChatMessage == nil {
            return "Error"
        }

        return lastChatMessage?.content
    }

    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: headline,
            subheadline: subheadline,
            isNewMessage: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task {
            lastChatMessage = await getLastChatMessage()
            didLoadChatMessage = true
        }
    }

}

#Preview {
    VStack {
        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        }, getLastChatMessage: {
            try? await Task.sleep(for: .seconds(0.25))
            return .mock
        })

        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            return .mock
        }, getLastChatMessage: {
            return .mock
        })

        ChatRowCellViewBuilder(chat: .mock, getAvatar: {
            return nil
        }, getLastChatMessage: {
            return nil
        })
    }
}
