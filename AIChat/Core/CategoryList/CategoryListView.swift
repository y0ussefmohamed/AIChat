//
//  CategoryListView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import SwiftUI

@MainActor
@Observable
class CategoryListViewModel {
    private let logManager: LogManager
    private let avatarManager: AvatarManager
    
    private(set) var avatars: [Avatar] = []
    private(set) var isLoading: Bool = true

    var alert: AnyAppAlert?
    
    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
    }
    
    func loadCategoryAvatars(category: CharacterOption?) async {
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

    func onRowTap(_ avatarId: String, navPathStack: Binding<[NavigationPathOption]>) {
        guard let avatar = avatars.first(where: { $0.avatarId == avatarId }) else {
            return
        }

        logManager.trackEvent(event: CategoryListEvent.avatarPressed(avatar: avatar))
        navPathStack.wrappedValue.append(.chat(avatarId))
    }
}

extension CategoryListViewModel {
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
}

struct CategoryListView: View {
    @State var viewModel: CategoryListViewModel
    
    var category: CharacterOption?
    var categoryImageName: String = Constants.randomImage
    @Binding var navPathStack: [NavigationPathOption]

    var body: some View {
        List {
            CategoryCellView(
                title: category?.pluralRawValue.capitalized,
                imageName: categoryImageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .accessibilityIdentifier(AccessibilityID.Category.title)
            .removeListRowFormatting()

            if viewModel.isLoading {
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
                if !viewModel.avatars.isEmpty {
                    ForEach(viewModel.avatars, id: \.self) { avatar in
                        CustomListCellView(
                            avatarName: avatar.name,
                            avatarDescription: avatar.characterDescription,
                            imageName: avatar.profileImageName
                        )
                        .styledButton(.highlighted) {
                            viewModel.onRowTap(avatar.avatarId, navPathStack: $navPathStack)
                        }
                        .accessibilityIdentifier(AccessibilityID.Category.avatar(avatar.avatarId))
                        .removeListRowFormatting()
                    }
                } else {
                    ContentUnavailableView(
                        "No \(category?.pluralRawValue.capitalized ?? "Avatars") Found",
                        systemImage: "person.fill.xmark",
                        description: Text("There are no avatars in this category yet. Check back later!")
                    )
                    .accessibilityIdentifier(AccessibilityID.Category.empty)
                    .listRowSeparator(.hidden)
                }

            }
        }
        .accessibilityIdentifier(AccessibilityID.Category.list)
        .task {
            await viewModel.loadCategoryAvatars(category: category)
        }
        .screenAppearAnalytics(viewName: "CategoryListView")
        .showCustomAlert(alert: $viewModel.alert)
        .ignoresSafeArea()
        .listStyle(.plain)
    }
}

#Preview("Has Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(services: MockAvatarServices(remote: MockAvatarService(delay: 2))))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), category: .man, navPathStack: .constant([]))
        .previewEnvironment()
}


#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(services: MockAvatarServices(remote: MockAvatarService(avatars: [], delay: 1))))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), category: .woman, navPathStack: .constant([]))
        .previewEnvironment()
}
