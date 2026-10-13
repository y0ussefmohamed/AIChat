//
//  CoreInteractor.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/10/2026.
//

import SwiftUI
import Foundation

/// CoreInteractor is a struct that has all the managers and contain the funcionality of all methods in managers
/// when it conforms to a protocol and this protocol have lets say needs 4 methods only from 2 managers.
/// this protocol type variable can be intialized with CoreInteractor and will only retrieve the functions needed by this protocol
@MainActor
struct CoreInteractor {
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    private let appState: AppState

    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.appState = container.resolve(AppState.self)!
    }

    // MARK: - AppState

    var showTabBar: Bool {
        appState.showTabBar
    }

    func updateAppState(showTabBar: Bool) {
        appState.updateViewState(showTabBar: showTabBar)
    }

    // MARK: - AuthManager

    var auth: UserAuthInfo? {
        authManager.auth
    }

    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }

    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }

    func signInApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInApple()
    }

    func signInEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInEmail(email: email, password: password)
    }

    func createAccountEmail(email: String, password: String) async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.createAccountEmail(email: email, password: password)
    }

    func deleteAccount() async throws {
        try await authManager.deleteAccount()
    }

    // MARK: - UserManager

    var currentUser: UserModel? {
        userManager.currentUser
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: auth, isNewUser: isNewUser)
    }

    func markOnboardingAsCompleted(profileColorHex: String) async throws {
        try await userManager.markOnboardingAsCompleted(profileColorHex: profileColorHex)
    }

    func deleteCurrentUser() async throws {
        try await userManager.deleteCurrentUser()
    }

    // MARK: - AIManager

    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }

    func generateText(input: String) async throws -> String {
        try await aiManager.generateText(input: input)
    }

    // MARK: - AvatarManager

    func addRecentAvatar(_ avatar: Avatar) async throws {
        try await avatarManager.addRecentAvatar(avatar)
    }

    func getRecentAvatars() throws -> [Avatar] {
        try avatarManager.getRecentAvatars()
    }

    func createAvatar(avatar: Avatar, image: UIImage) async throws {
        try await avatarManager.createAvatar(avatar: avatar, image: image)
    }

    func getAvatar(id: String) async throws -> Avatar {
        try await avatarManager.getAvatar(id: id)
    }

    func deleteAvatar(id: String) async throws {
        try await avatarManager.deleteAvatar(id: id)
    }

    func getFeaturedAvatars() async throws -> [Avatar] {
        try await avatarManager.getFeaturedAvatars()
    }

    func getPopularAvatars() async throws -> [Avatar] {
        try await avatarManager.getPopularAvatars()
    }

    func getAvatarsByCategory(_ category: CharacterOption) async throws -> [Avatar] {
        try await avatarManager.getAvatarsByCategory(category)
    }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar] {
        try await avatarManager.getCurrentUserAvatars(userId: userId)
    }

    func removeAuthorIdFromTheDeletedUserAvatars(userId: String) async throws {
        try await avatarManager.removeAuthorIdFromTheDeletedUserAvatars(userId: userId)
    }

    // MARK: - ChatManager

    func streamChatChanges(chatId: String) -> AsyncThrowingStream<[ChatMessage], Error> {
        chatManager.streamChatChanges(chatId: chatId)
    }

    func createNewChat(chat: Chat) async throws {
        try await chatManager.createNewChat(chat: chat)
    }

    func addChatMessage(message: ChatMessage) async throws {
        try await chatManager.addChatMessage(message: message)
    }

    func loadChat(userId: String, avatarId: String) async throws -> Chat? {
        try await chatManager.loadChat(userId: userId, avatarId: avatarId)
    }

    func loadChats(userId: String) async throws -> [Chat] {
        try await chatManager.loadChats(userId: userId)
    }

    func userHasSeenMessage(messageId: String, chatId: String, userId: String) async throws {
        try await chatManager.userHasSeenMessage(messageId: messageId, chatId: chatId, userId: userId)
    }

    func deleteChat(chatId: String) async throws {
        try await chatManager.deleteChat(chatId: chatId)
    }

    func deleteAllChats(userId: String) async throws {
        try await chatManager.deleteAllChats(userId: userId)
    }

    func reportChat(chatId: String?, userId: String) async throws {
        try await chatManager.reportChat(chatId: chatId, userId: userId)
    }

    // MARK: - LogManager

    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }

    func addUserProperties(properties: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(properties: properties, isHighPriority: isHighPriority)
    }

    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }

    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }

    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }

    func trackScreenEvent(event: any LoggableEvent) {
        logManager.trackScreenEvent(event: event)
    }

    // MARK: - PushManager

    func isAuthorized() async -> Bool {
        await pushManager.isAuthorized()
    }

    func requestAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }

    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }

    func schedulePushNotificationsForTheNextWeek() async throws {
        try await pushManager.schedulePushNotificationsForTheNextWeek()
    }

    // MARK: - ABTestManager

    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }

    var canOverrideTests: Bool {
        abTestManager.canOverrideTests
    }

    func override(updatedTests: ActiveABTests) throws {
        try abTestManager.override(updatedTests: updatedTests)
    }

    // MARK: - Shared

    func deleteUserAccount(userId: String) async throws {
        async let removeAvatars = avatarManager.removeAuthorIdFromTheDeletedUserAvatars(userId: userId)
        async let deleteUser = userManager.deleteCurrentUser()
        async let deleteAuth = authManager.deleteAccount()
        async let deleteChats = chatManager.deleteAllChats(userId: userId)

        _ = try await (removeAvatars, deleteUser, deleteAuth, deleteChats)
    }

    func signOut() throws {
        try authManager.signOut()
        userManager.signOut()
    }
}
