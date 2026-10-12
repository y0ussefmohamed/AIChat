//
//  ProfileView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

@MainActor
struct ProductionProfileInteractor: ProfileInteractor {
    private let logManager: LogManager
    private let authManager: AuthManager
    private let userManager: UserManager
    private let avatarManager: AvatarManager

    var currentUser: UserModel? {
        userManager.currentUser
    }

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
    }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] {
        return try await avatarManager.getCurrentUserAvatars(userId: userId)
    }

    func deleteAvatar(id: String) async throws {
        try await avatarManager.deleteAvatar(id: id)
    }


    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}


/// this protocol carries the functions that is called by the view model from the managers
/// to decouple the view model from the managers
protocol ProfileInteractor {
    var currentUser: UserModel? { get }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar]
    func deleteAvatar(id: String) async throws
    func trackEvent(event: any LoggableEvent)
}

@MainActor
@Observable
class ProfileViewModel {
    /// the view model depends on the interactor, which only has the functions needed by this view model
    private let interactor: ProfileInteractor

    private(set) var currentUser: UserModel?
    private(set) var currentUserAvatars: [Avatar] = []

    var isLoading: Bool = false
    var showSettingsView: Bool = false
    var showCreateAvatarView: Bool = false
    var alert: AnyAppAlert?
    var navPathStack: [String] = []

    init(interactor: ProfileInteractor) {
        self.interactor = interactor
    }

    func loadData() async {
        self.currentUser = interactor.currentUser

        isLoading = true
        if let userId = currentUser?.userId {
            interactor.trackEvent(event: ProfileViewEvent.loadAvatarsStart)
            do {
                currentUserAvatars = try await interactor.getCurrentUserAvatars(userId: userId)
                interactor.trackEvent(event: ProfileViewEvent.loadAvatarsSuccess(count: currentUserAvatars.count))
            } catch {
                interactor.trackEvent(event: ProfileViewEvent.loadAvatarsFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
        isLoading = false
    }

    func onSettingsButtonPressed() {
        interactor.trackEvent(event: ProfileViewEvent.settingsButtonPressed)
        showSettingsView = true
    }

    func onNewAvatarButtonPressed() {
        interactor.trackEvent(event: ProfileViewEvent.newAvatarButtonPressed)
        showCreateAvatarView = true
    }

    func onAvatarPressed(avatar: Avatar) {
        interactor.trackEvent(event: ProfileViewEvent.avatarPressed(avatar: avatar))
        navPathStack.append(avatar.avatarId)
    }

    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatarToDelete = currentUserAvatars[index]
        currentUserAvatars.remove(atOffsets: IndexSet(integer: index))

        interactor.trackEvent(event: ProfileViewEvent.deleteAvatarStart(avatar: avatarToDelete))

        Task {
            do {
                try await interactor.deleteAvatar(id: avatarToDelete.avatarId)
                interactor.trackEvent(event: ProfileViewEvent.deleteAvatarSuccess(avatar: avatarToDelete))
            } catch {
                interactor.trackEvent(event: ProfileViewEvent.deleteAvatarFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }
}

extension ProfileViewModel {
    enum ProfileViewEvent: LoggableEvent {
        case loadAvatarsStart, loadAvatarsSuccess(count: Int), loadAvatarsFail(error: Error)
        case settingsButtonPressed
        case newAvatarButtonPressed
        case avatarPressed(avatar: Avatar)
        case deleteAvatarStart(avatar: Avatar), deleteAvatarSuccess(avatar: Avatar), deleteAvatarFail(error: Error)

        var eventName: String {
            switch self {
            case .loadAvatarsStart:
                return "ProfileView_LoadAvatars_Start"
            case .loadAvatarsSuccess:
                return "ProfileView_LoadAvatars_Success"
            case .loadAvatarsFail:
                return "ProfileView_LoadAvatars_Fail"
            case .settingsButtonPressed:
                return "ProfileView_Settings_Pressed"
            case .newAvatarButtonPressed:
                return "ProfileView_NewAvatar_Pressed"
            case .avatarPressed:
                return "ProfileView_Avatar_Pressed"
            case .deleteAvatarStart:
                return "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess:
                return "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFail:
                return "ProfileView_DeleteAvatar_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarsSuccess(count: let count):
                return count.asEventParameter(key: "avatar_count")
            case .loadAvatarsFail(error: let error),
                 .deleteAvatarFail(error: let error):
                return error.asEventParameter
            case .avatarPressed(avatar: let avatar),
                 .deleteAvatarStart(avatar: let avatar),
                 .deleteAvatarSuccess(avatar: let avatar):
                return avatar.asEventParameter
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadAvatarsFail, .deleteAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

struct ProfileView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack(path: $viewModel.navPathStack) {
            List {
                Section {
                    Circle()
                        .fill(viewModel.currentUser?.profileColor ?? .accent)
                        .frame(width: 100, height: 100)
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Profile color")
                        .accessibilityValue(viewModel.currentUser?.profileColorHex ?? "Accent")
                        .accessibilityIdentifier(AccessibilityID.Profile.color)
                }
                .removeListRowFormatting()

                Section {
                    if viewModel.currentUserAvatars.isEmpty {
                        if viewModel.isLoading {
                            ProgressView()
                                .removeListRowFormatting()
                                .frame(maxWidth: .infinity)
                        } else {
                            emptyAvatarsView
                                .removeListRowFormatting()
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        ForEach(viewModel.currentUserAvatars, id: \.self) { avatar in
                            CustomListCellView(
                                avatarName: avatar.name,
                                avatarDescription: nil,
                                imageName: avatar.profileImageName
                            )
                            .styledButton(.pressable) {
                                viewModel.onAvatarPressed(avatar: avatar)
                            }
                            .accessibilityIdentifier(AccessibilityID.Profile.avatar(avatar.avatarId))
                        }
                        .onDelete(perform: viewModel.onDeleteAvatar)
                        .removeListRowFormatting()
                    }
                } header: {
                    HStack {
                        Text("My Avatars")
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.accent)
                            .tappableBackground()
                            .styledButton(action: viewModel.onNewAvatarButtonPressed)
                            .accessibilityLabel("Create avatar")
                            .accessibilityIdentifier(AccessibilityID.Profile.createAvatar)
                    }
                    .padding(.horizontal, 8)
                }
            }
            .accessibilityIdentifier(AccessibilityID.Profile.list)
            .screenAppearAnalytics(viewName: "ProfileView")
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingsButton
                }
            }
            .navigationDestination(for: String.self) { avatarId in
                ChatView(avatarId: avatarId)
            }
        }
        .showCustomAlert(alert: $viewModel.alert)
        .task {
            await viewModel.loadData()
        }
        .sheet(isPresented: $viewModel.showSettingsView, onDismiss: {
            Task {
                await viewModel.loadData()
            }
        }, content: {
            SettingsView()
        })
        .fullScreenCover(isPresented: $viewModel.showCreateAvatarView, onDismiss: {
            Task {
                await viewModel.loadData()
            }
        }, content: {
            CreateAvatarView(
                viewModel: CreateAvatarViewModel(container: container)
            )
        })
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .styledButton(action: viewModel.onSettingsButtonPressed)
            .accessibilityLabel("Settings")
            .accessibilityIdentifier(AccessibilityID.Profile.settings)
    }

    private var emptyAvatarsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.secondary)

            Text("No Avatars Yet")
                .accessibilityIdentifier(AccessibilityID.Profile.empty)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Create your first custom avatar to get started.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Create Avatar")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.15))
                .foregroundStyle(.accent)
                .clipShape(Capsule())
                .padding(.top, 8)
                .styledButton(.pressable, action: viewModel.onNewAvatarButtonPressed)
                .accessibilityIdentifier(AccessibilityID.Profile.emptyCreate)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            viewModel: ProfileViewModel(interactor: ProductionProfileInteractor(container: DevPreview.shared.container))
        )
    }
    .previewContainerEnvironment()
    .previewEnvironment()
}
