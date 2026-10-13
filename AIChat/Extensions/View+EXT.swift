//
//  View+EXT.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

extension View {
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        modifier(FirstAppearModifier(action: action))
    }

    func callToActionButton(buttonColor: Color = .accent) -> some View {
        self
            .modifier(CTAButtonViewModifier(buttonColor: buttonColor))
    }

    func badgeButtonModifier() -> some View {
        self
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(.blue)
            .cornerRadius(10)
            .foregroundColor(.white)
    }

    func tappableBackground() -> some View {
        background(Color.black.opacity(0.001))
    }

    func removeListRowFormatting() -> some View {
        self
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
    }

    func visibleGradientBackground() -> some View {
        background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.3)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    func chatBubbleModifier(textUIColor: UIColor, backgroundColor: Color) -> some View {
        self
            .foregroundStyle(Color(uiColor: textUIColor))
            .padding(13)
            .background(backgroundColor)
            .cornerRadius(10)
    }

    func showCustomAlert(alert: Binding<AnyAppAlert?>) -> some View {
        self
            .alert(alert.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: alert)) {
                alert.wrappedValue?.buttons()
            } message: {
                if let subtitle = alert.wrappedValue?.subtitle {
                    Text(subtitle)
                }
            }
    }

    @ViewBuilder
    func ifSatisfiedCondition(_ satisfyCondtion: Bool, action: (Self) -> some View) -> some View {
        if satisfyCondtion {
            action(self)
        } else {
            self
        }
    }

    func showModal<Content: View>(
        isPresented: Binding<Bool>,
        transition: AnyTransition = .slide,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .overlay {
                ModalSupportView(showProfileModal: isPresented) {
                    content()
                        .transition(transition)
                }
            }
    }

    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }

    func screenAppearAnalytics(viewName: String) -> some View {
        self
            .modifier(AppearAnalyticsViewModifier(viewName: viewName))
    }
}

extension View {
    func previewEnvironment(
        isSignedIn: Bool = true,
        remoteAvatarService: RemoteAvatarService = MockAvatarService(),
        localAvatarPersistence: LocalAvatarPersistence = MockLocalAvatarPersistence()
    ) -> some View {
        self
            .environment(DevPreview.shared.container)
            .environment(UserManager(services: MockUserServicesContainer(user: isSignedIn ? .mock : nil)))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(AvatarManager(services: MockAvatarServices(remote: remoteAvatarService, local: localAvatarPersistence)))
            .environment(AIManager(aiServices: MockAIServices()))
            .environment(ChatManager(service: MockChatService()))
            .environment(LogManager(services: []))
            .environment(PushManager())
            .environment(ABTestManager(service: MockABTestService()))
    }

    @MainActor
    func previewContainerEnvironment(
        isSignedIn: Bool = true,
        remoteAvatarService: RemoteAvatarService = MockAvatarService(),
        localAvatarPersistence: LocalAvatarPersistence = MockLocalAvatarPersistence()
    ) -> some View {
        let container = DependencyContainer()
        let logManager = LogManager(services: [])

        container.register(LogManager.self, service: logManager)

        container.register(AuthManager.self, service: AuthManager(
            service: MockAuthService(user: isSignedIn ? .mock() : nil),
            logManager: logManager
        ))

        container.register(UserManager.self, service: UserManager(
            services: MockUserServicesContainer(user: isSignedIn ? .mock : nil),
            logManager: logManager
        ))

        container.register(AvatarManager.self, service: AvatarManager(
            services: MockAvatarServices(
                remote: remoteAvatarService,
                local: localAvatarPersistence
            )
        ))

        container.register(AIManager.self, service: AIManager(
            aiServices: MockAIServices()
        ))

        container.register(ChatManager.self, service: ChatManager(
            service: MockChatService()
        ))

        container.register(PushManager.self, service: PushManager())

        container.register(ABTestManager.self, service: ABTestManager(
            service: MockABTestService(),
            logManager: logManager
        ))

        container.register(AppState.self, service: AppState(showTabBar: isSignedIn))

        return self.environment(container)
    }
}
