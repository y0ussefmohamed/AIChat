//
//  ProfileView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @State private var showSettingsView: Bool = false
    @State private var showCreateAvatarView: Bool = false

    @State private var currentUser: UserModel?
    @State private var myAvatars: [Avatar] = []
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
                    if myAvatars.isEmpty {
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
                        ForEach(myAvatars, id: \.self) { avatar in
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
        .task {
            await loadData()
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCreateAvatarView) {
            CreateAvatarView()
        }
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
        navPathStack.append(avatar.avatarId)
    }
}

// MARK: - Seperate Business Logic out of Views
extension ProfileView {
    private func onSettingsButtonPressed() {
        showSettingsView = true
    }

    private func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
    }

    private func loadData() async {
        self.currentUser = userManager.currentUser

        isLoading = true
        try? await Task.sleep(for: .seconds(1)) // mocking get request
        isLoading = false

        self.myAvatars = Avatar.mocks
    }

    private func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        myAvatars.remove(atOffsets: IndexSet(integer: index))
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
            .environment(AuthManager(service: MockAuthService(user: .mock())))
    }
}
