/// Shared by the app and UI-test runner. Identifiers describe roles, not visible wording.
enum AccessibilityID {
    enum Welcome {
        static let title = "welcome.title"
        static let getStarted = "welcome.getStarted"
        static let signIn = "welcome.signIn"
        static let terms = "welcome.terms"
        static let privacy = "welcome.privacy"
    }

    enum Onboarding {
        static let intro = "onboarding.intro"
        static let introContinue = "onboarding.intro.continue"
        static let community = "onboarding.community"
        static let communityIllustration = "onboarding.community.illustration"
        static let communityContinue = "onboarding.community.continue"
        static let colorTitle = "onboarding.color.title"
        static let colorContinue = "onboarding.color.continue"
        static let completed = "onboarding.completed"
        static let finish = "onboarding.finish"
        static func color(_ index: Int) -> String { "onboarding.color.\(index)" }
    }

    enum Account {
        static let title = "account.title"
        static let fullName = "account.fullName"
        static let email = "account.email"
        static let password = "account.password"
        static let passwordVisibility = "account.passwordVisibility"
        static let submit = "account.submit"
        static let switchMode = "account.switchMode"
        static let apple = "account.apple"
    }

    enum Explore {
        static let list = "explore.list"
        static let featuredTitle = "explore.featured.title"
        static let popularTitle = "explore.popular.title"
        static let categoriesTitle = "explore.categories.title"
        static let carousel = "explore.carousel"
        static let categories = "explore.categories"
        static let notifications = "explore.notifications"
        static let developerSettings = "explore.developerSettings"
        static func featured(_ avatarId: String) -> String { "explore.featured.\(avatarId)" }
        static func popular(_ avatarId: String) -> String { "explore.popular.\(avatarId)" }
        static func category(_ option: String) -> String { "explore.category.\(option)" }
    }

    enum Category {
        static let list = "category.list"
        static let title = "category.title"
        static let empty = "category.empty"
        static func avatar(_ avatarId: String) -> String { "category.avatar.\(avatarId)" }
    }

    enum Profile {
        static let list = "profile.list"
        static let color = "profile.color"
        static let settings = "profile.settings"
        static let createAvatar = "profile.createAvatar"
        static let empty = "profile.empty"
        static let emptyCreate = "profile.empty.createAvatar"
        static func avatar(_ avatarId: String) -> String { "profile.avatar.\(avatarId)" }
    }

    enum CreateAvatar {
        static let list = "createAvatar.list"
        static let name = "createAvatar.name"
        static let character = "createAvatar.character"
        static let action = "createAvatar.action"
        static let location = "createAvatar.location"
        static let generate = "createAvatar.generate"
        static let generating = "createAvatar.generating"
        static let generatedImage = "createAvatar.generatedImage"
        static let save = "createAvatar.save"
        static let close = "createAvatar.close"
        static func characterOption(_ value: String) -> String { "createAvatar.character.\(value)" }
        static func actionOption(_ value: String) -> String { "createAvatar.action.\(value)" }
        static func locationOption(_ value: String) -> String { "createAvatar.location.\(value)" }
    }

    enum Chats {
        static let list = "chats.list"
        static let empty = "chats.empty"
        static let explore = "chats.explore"
        static let recents = "chats.recents"
        static func recent(_ avatarId: String) -> String { "chats.recent.\(avatarId)" }
        static func row(_ chatId: String) -> String { "chats.row.\(chatId)" }
    }

    enum Chat {
        static let scroll = "chat.scroll"
        static let composer = "chat.composer"
        static let send = "chat.send"
        static let actions = "chat.actions"
        static let emptyAvatar = "chat.empty.avatar"
        static let starter = "chat.starter"
        static let typing = "chat.typing"
        static let messagePrefix = "chat.message."
        static func message(_ messageId: String) -> String { messagePrefix + messageId }
        static func timestamp(_ messageId: String) -> String { "chat.timestamp.\(messageId)" }
        static func avatarImage(_ messageId: String) -> String { "chat.avatar.\(messageId)" }
    }

    enum Settings {
        static let list = "settings.list"
        static let signOut = "settings.signOut"
        static let deleteAccount = "settings.deleteAccount"
        static let backup = "settings.backup"
        static let premium = "settings.premium"
        static let manage = "settings.manage"
        static let rating = "settings.rating"
        static let version = "settings.version"
        static let build = "settings.build"
        static let contact = "settings.contact"
    }

    enum DeveloperSettings {
        static let list = "developerSettings.list"
        static let createAccount = "developerSettings.createAccount"
        static let community = "developerSettings.community"
        static let categoryRow = "developerSettings.categoryRow"
        static let close = "developerSettings.close"
        static func categoryOption(_ value: String) -> String { "developerSettings.categoryRow.\(value)" }
    }

    enum Modal {
        static let rating = "modal.rating"
        static let notifications = "modal.notifications"
        static let backdrop = "modal.backdrop"
        static let profileTitle = "modal.profile.title"
        static let profileSubtitle = "modal.profile.subtitle"
        static let profileImage = "modal.profile.image"
        static let profileClose = "modal.profile.close"
        static func title(_ modal: String) -> String { modal + ".title" }
        static func primary(_ modal: String) -> String { modal + ".primary" }
        static func secondary(_ modal: String) -> String { modal + ".secondary" }
    }
}
