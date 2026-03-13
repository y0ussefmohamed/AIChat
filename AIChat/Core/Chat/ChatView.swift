//
//  ChatView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

struct ChatView: View {
    @State private var chatMessages: [ChatMessage] = ChatMessage.mocks
    @State private var avatar: Avatar? = .mock
    @State private var currentUser: User? = .mock

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(chatMessages) { message in
                        ChatBubbleViewBuilder(
                            isAvatar: message.authorId == currentUser?.userId,
                            imageName: avatar?.profileImageName,
                            message: message
                        )
                    }
                }
                .padding(8)
            }

            Rectangle()
                .frame(height: 50)
        }
        .navigationTitle(avatar?.name ?? "Unknown")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
