//
//  ChatsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

// What do we need in this screen?
/// 1. The Avatar Model to get the image, username of the avatar that sent the message
/// 2. The ChatMessage Model to get the latest message and check if the user has seen the message or not

/// This means we need to make a `ViewBuilder` in order to fetch those Models with the avatarId and chatId to get our desired data, and we can't do this here because we can't make .task{} in each item in the for loop, we don't want to load the view unless we have the data to show

struct ChatsView: View {
    @State private var chats: [Chat] = Chat.mocks

    var body: some View {
        NavigationStack {
            List {
                ForEach(chats) { chat in
                    /// use a `ViewBuilder` wrapper when the view of the for loop depends on its items (the `chat` item in our case)
                    ChatRowCellViewBuilder(
                        currentUserId: nil,
                        chat: chat,
                        getAvatar: {
                            // Get Avatar by chat.avatarId
                            return .mock
                        },
                        getLastChatMessage: {
                            // Get Last Chat Message by chat.id
                            return .mock
                        }
                    )
                    .styledButton(.pressable) {

                    }
                    .removeListRowFormatting()
                }
            }
            .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatsView()
}
