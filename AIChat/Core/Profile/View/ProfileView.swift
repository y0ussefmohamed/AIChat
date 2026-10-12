//
//  ProfileView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI




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
            viewModel: ProfileViewModel(interactor: CoreInteractor(container: DevPreview.shared.container))
        )
    }
    .previewContainerEnvironment()
    .previewEnvironment()
}
