//
//  carries.swift
//  AIChat
//
//  Created by Youssef Mohamed on 13/10/2026.
//

import Foundation

/// this protocol carries the functions that is called by the view model from the managers
/// to decouple the view model from the managers
/// this interactor protocol is asking the CoreInteractor for these methods implementation
protocol ProfileInteractor {
    var currentUser: UserModel? { get }

    func getCurrentUserAvatars(userId: String) async throws -> [Avatar]
    func deleteAvatar(id: String) async throws
    func trackEvent(event: any LoggableEvent)
}
extension CoreInteractor: ProfileInteractor {} /// the `CoreInteractor` will only expose methods in this protocol
/// CoreInteractor is used to solve the problem of not doing a seperate ClassInteractor for every ViewModel, this would be too much
