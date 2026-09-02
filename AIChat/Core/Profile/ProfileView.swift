//
//  ProfileView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @State private var showSettingsView: Bool = false
    @State private var showCreateAvatarView: Bool = false
    @State private var alert: AnyAppAlert?
    @State private var currentUser: UserModel?
    @State private var currentUserAvatars: [Avatar] = []
    @State private var isLoading: Bool = false

    @State private var navPathStack: [String] = []
    var body: some View {
        NavigationStack(path: $navPathStack) {
            List {
                Section {
                    Circle()
                        .fill(currentUser?.profileColor ?? .accent)
                        .frame(width: 100, height: 100)
                        .frame(maxWidth: .infinity)
                }
                .removeListRowFormatting()

                Section {
                    if currentUserAvatars.isEmpty {
                        if isLoading {
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
                        ForEach(currentUserAvatars, id: \.self) { avatar in
                            CustomListCellView(
                                avatarName: avatar.name,
                                avatarDescription: nil,
                                imageName: avatar.profileImageName
                            )
                            .styledButton(.pressable) {
                                onAvatarPressed(avatar)
                            }
                        }
                        .onDelete(perform: onDeleteAvatar)
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
                            .styledButton(action: onNewAvatarButtonPressed)
                    }
                    .padding(.horizontal, 8)
                }
            }
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
        .showCustomAlert(alert: $alert)
        .task {
            await loadData()
        }
        .sheet(isPresented: $showSettingsView, onDismiss: {
            Task {
                await loadData()
            }
        }, content: {
            SettingsView()
        })
        .fullScreenCover(isPresented: $showCreateAvatarView, onDismiss: {
            Task {
                await loadData()
            }
        }, content: {
            CreateAvatarView()
        })
    }

    private var settingsButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .styledButton(action: onSettingsButtonPressed)
    }

    private var emptyAvatarsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(.secondary)

            Text("No Avatars Yet")
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
                    .styledButton(.pressable, action: onNewAvatarButtonPressed)
        }
    }

    private func onAvatarPressed(_ avatar: Avatar) {
        logManager.trackEvent(event: ProfileViewEvent.avatarPressed(avatar: avatar))
        navPathStack.append(avatar.avatarId)
    }
}

// MARK: - Seperate Business Logic out of Views
extension ProfileView {
    private func onSettingsButtonPressed() {
        logManager.trackEvent(event: ProfileViewEvent.settingsButtonPressed)
        showSettingsView = true
    }

    private func onNewAvatarButtonPressed() {
        logManager.trackEvent(event: ProfileViewEvent.newAvatarButtonPressed)
        showCreateAvatarView = true
    }

    private func loadData() async {
        self.currentUser = userManager.currentUser

        isLoading = true
        if let userId = currentUser?.userId {
            logManager.trackEvent(event: ProfileViewEvent.loadAvatarsStart)
            do {
                currentUserAvatars = try await avatarManager.getCurrentUserAvatars(userId: userId)
                logManager.trackEvent(event: ProfileViewEvent.loadAvatarsSuccess(count: currentUserAvatars.count))
            } catch {
                logManager.trackEvent(event: ProfileViewEvent.loadAvatarsFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
        isLoading = false
    }

    private func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatarToDelete = currentUserAvatars[index]
        currentUserAvatars.remove(atOffsets: IndexSet(integer: index))

        logManager.trackEvent(event: ProfileViewEvent.deleteAvatarStart(avatar: avatarToDelete))

        Task {
            do {
                try await avatarManager.deleteAvatar(id: avatarToDelete.avatarId)
                logManager.trackEvent(event: ProfileViewEvent.deleteAvatarSuccess(avatar: avatarToDelete))
            } catch {
                logManager.trackEvent(event: ProfileViewEvent.deleteAvatarFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }
}

extension ProfileView {
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

#Preview {
    NavigationStack {
        ProfileView()
            .environment(LogManager(services: [ConsoleService()]))
            .previewEnvironment()
    }
}
