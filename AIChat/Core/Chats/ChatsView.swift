//
//  ChatsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ChatsView: View {
    @State private var chats: [Chat] = Chat.mocks

    var body: some View {
        NavigationStack {
            List(chats) { chat in
                Text(chat.id)
            }
            .navigationTitle("Chats")
        }
    }
}

#Preview {
    ChatsView()
}
