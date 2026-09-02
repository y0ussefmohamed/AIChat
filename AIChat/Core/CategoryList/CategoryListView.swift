//
//  CategoryListView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AvatarManager.self) private var avatarManager
    var category: CharacterOption?
    var categoryImageName: String = Constants.randomImage
    @State private var avatars: [Avatar] = []
    @State private var alert: AnyAppAlert?

    @State private var isLoading: Bool = true

    /// We did this because:
    /// This View is in a `NavigationStack` already, so we can bind the navPathStack from this View to the navPathStack that's in the previous NavigationStack (Which this View came from)
    @Binding var navPathStack: [NavigationPathOption]

    var body: some View {
        List {
            CategoryCellView(
                title: category?.pluralRawValue.capitalized,
                imageName: categoryImageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()

            if isLoading {
                ForEach(0..<5, id: \.self) { _ in
                    CustomListCellView(
                        avatarName: "Loading Name",
                        avatarDescription: "This is a placeholder, to look like real data.",
                        imageName: Constants.randomImage
                    )
                    .redacted(reason: .placeholder)
                    .removeListRowFormatting()
                }
            } else {
                if !avatars.isEmpty {
                    ForEach(avatars, id: \.self) { avatar in
                        CustomListCellView(
                            avatarName: avatar.name,
                            avatarDescription: avatar.characterDescription,
                            imageName: avatar.profileImageName
                        )
                        .styledButton(.highlighted) {
                            onRowTap(avatar.avatarId)
                        }
                        .removeListRowFormatting()
                    }
                } else {
                    ContentUnavailableView(
                        "No \(category?.pluralRawValue.capitalized ?? "Avatars") Found",
                        systemImage: "person.fill.xmark",
                        description: Text("There are no avatars in this category yet. Check back later!")
                    )
                    .listRowSeparator(.hidden)
                }

            }
        }
        .onAppear {
            loadCategoryAvatars()
        }
        .screenAppearAnalytics(viewName: "CategoryListView")
        .showCustomAlert(alert: $alert)
        .ignoresSafeArea()
        .listStyle(.plain)
    }

    enum CategoryListEvent: LoggableEvent {
        case loadAvatarStart, loadAvatarSuccess, loadAvatarFail(error: Error)
        case avatarPressed(avatar: Avatar)

        var eventName: String {
            switch self {
            case .loadAvatarStart:
                return "CategoryListView_LoadAvatar_Start"
            case .loadAvatarSuccess:
                return "CategoryListView_LoadAvatar_Success"
            case .loadAvatarFail:
                return "CategoryListView_LoadAvatar_Fail"
            case .avatarPressed:
                return "CategoryListView_Avatar_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(error: let error):
                return error.asEventParameter
            case .avatarPressed(avatar: let avatar):
                return avatar.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }

    private func loadCategoryAvatars() {
        Task {
            defer { isLoading = false }

            logManager.trackEvent(event: CategoryListEvent.loadAvatarStart)
            do {
                if let category {
                    avatars = try await avatarManager.getAvatarsByCategory(category)
                }
                logManager.trackEvent(event: CategoryListEvent.loadAvatarSuccess)
            } catch {
                logManager.trackEvent(event: CategoryListEvent.loadAvatarFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }

    private func onRowTap(_ avatarId: String) {
        guard let avatar = avatars.first(where: { $0.avatarId == avatarId }) else {
            return
        }

        logManager.trackEvent(event: CategoryListEvent.avatarPressed(avatar: avatar))
        navPathStack.append(.chat(avatarId))
    }
}

#Preview("Has Data") {
    CategoryListView(category: .man, navPathStack: .constant([]))
        .environment(LogManager(services: [ConsoleService()]))
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 2))))
}

#Preview("No Data") {
    CategoryListView(category: .woman, navPathStack: .constant([]))
        .environment(LogManager(services: [ConsoleService()]))
        .environment(AvatarManager(services: MockAvatarServices(remote: MockAvatarService(avatars: [], delay: 1))))
}
