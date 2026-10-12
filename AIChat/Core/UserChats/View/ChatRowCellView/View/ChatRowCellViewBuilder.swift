//
//  ChatRowCellViewBuilder.swift
//  AIChat
//
//  Created by Youssef Mohamed on 10/03/2026.
//

import SwiftUI

/// Fetches the avatar and observes messages needed to display one chat row.
/// Each row owns its tasks, so SwiftUI cancels them when the row disappears.
struct ChatRowCellViewBuilder: View {
    @State var viewModel: ChatRowCellViewModel

    var body: some View {
        ChatRowCellView(
            imageName: viewModel.avatar?.profileImageName,
            headline: viewModel.headline,
            subheadline: viewModel.subheadline,
            isNewMessage: viewModel.isNewMessage
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .task {
            await viewModel.loadAvatar()
        }
        .task {
            await viewModel.streamLastMessage()
        }
    }
}

// MARK: - Preview

#Preview("3 Chat Row Cells") {
    VStack {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: PreviewChatRowCellInteractor(avatarDelay: 5, messageDelay: 0.25),
                chatId: Chat.mock.id,
                avatarId: Avatar.mock.avatarId
            )
        )
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: PreviewChatRowCellInteractor(),
                chatId: Chat.mock.id,
                avatarId: Avatar.mock.avatarId
            )
        )
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(
                interactor: PreviewChatRowCellInteractor(avatar: nil, message: nil),
                chatId: Chat.mock.id,
                avatarId: Avatar.mock.avatarId
            )
        )
    }
}

@MainActor
private struct PreviewChatRowCellInteractor: ChatRowCellInteractor {
    var currentUser: UserModel? { .mock }
    var avatar: Avatar? = .mock
    var message: ChatMessage? = .mock
    var avatarDelay: Double = 0
    var messageDelay: Double = 0

    func getAvatar(id: String) async throws -> Avatar {
        try await Task.sleep(for: .seconds(avatarDelay))
        guard let avatar else { throw URLError(.resourceUnavailable) }
        return avatar
    }

    func streamChatChanges(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await Task.sleep(for: .seconds(messageDelay))
                    continuation.yield(message.map { [$0] } ?? [])
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    func trackEvent(event: any LoggableEvent) { }
}
