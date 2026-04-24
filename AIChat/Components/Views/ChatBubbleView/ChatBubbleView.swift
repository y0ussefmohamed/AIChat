//
//  ChatBubbleView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

// This View uses only primitiv types (Text, String, Bool, etc...), independent to Any Model
struct ChatBubbleView: View {
    var isAvatar: Bool = true
    var avatarImageName: String?
    var text: String = "Hey, How are You?"
    var onImagePressed: (() -> Void)?
    var bubbleColor: Color = .blue

    var body: some View {
        VStack {
            if isAvatar {
                HStack {
                    ZStack {
                        if let avatarImageName, !avatarImageName.isEmpty {
                            ImageLoaderView(imageUrlString: avatarImageName)
                                .onTapGesture {
                                    onImagePressed?()
                                }
                        } else {
                            Rectangle()
                                .fill(.gray.opacity(0.7))
                        }
                    }
                    .clipShape(Circle())
                    .frame(width: 45, height: 45)

                    Text(text)
                        .chatBubbleModifier(textUIColor: .label, backgroundColor: .gray.opacity(0.2))
                }
            } else {
                Text(text)
                    .chatBubbleModifier(textUIColor: .systemBackground, backgroundColor: bubbleColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: isAvatar ? .leading : .trailing)
    }
}

#Preview("4 Chat Bubbles") {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleView(isAvatar: false, avatarImageName: Constants.randomImage)
            ChatBubbleView(isAvatar: true)
            ChatBubbleView(isAvatar: false)
            ChatBubbleView(isAvatar: true, avatarImageName: Constants.randomImage)
        }
        .padding()
    }
    .previewEnvironment()
}
