//
//  ChatBubbleViewBuilder.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/03/2026.
//

import SwiftUI

/// This `ViewBuilder` is Created to use the `ChatBubbleView` as a reusable component, but this `ViewBuilder` is used to receive the message from the forEach and display the ChatBubbleView but with the inputs here
struct ChatBubbleViewBuilder: View {
    var isAvatar: Bool = true
    var imageName: String?
    var message: ChatMessage = .mock
    var onImagePressed: (() -> Void)?

    var body: some View {
        ZStack {
            ChatBubbleView(
                isAvatar: isAvatar,
                avatarImageName: imageName,
                text: message.content ?? "",
                onImagePressed: onImagePressed
            )
            .padding(.leading, isAvatar ? 0 : 75) /// if the currentUser typed a very long message it doesn't go in the avatar's section in the UI
            .padding(.trailing, isAvatar ? 75 : 0) /// same for the avatars' message
        }
    }
}

#Preview {
    GeometryReader { proxy in
        ScrollView {
            VStack(spacing: 24) {
                ChatBubbleViewBuilder(isAvatar: true, message: ChatMessage(id: UUID().uuidString, chatId: "323", authorId: "434`", content: "This is a very big text by the current avatar,This is a very big text by the current avatar,This is a very big text by the current avatar,This is a very big text by the current avatar", seenByIds: nil, dateCreated: Date.now))

                ChatBubbleViewBuilder(isAvatar: false)

                ChatBubbleViewBuilder(isAvatar: true)

                ChatBubbleViewBuilder(isAvatar: false, message: ChatMessage(id: UUID().uuidString, chatId: "323", authorId: "434`", content: "This is a very big text by the current user,This is a very big text by the current user,This is a very big text by the current user,This is a very big text by the current user", seenByIds: nil, dateCreated: Date.now))
            }
            .padding()
            /// Force the inner VStack to be at least the height of the screen, not infinity
            .frame(minHeight: proxy.size.height, alignment: .bottom)
        }
        /// This ensures that when your messages overflow the screen, it starts at the bottom rather than the top (iOS 17+).
        .defaultScrollAnchor(.bottom)
    }
}
