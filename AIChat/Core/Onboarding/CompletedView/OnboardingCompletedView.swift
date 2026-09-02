//
//  OnboardingCompletedView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(LogManager.self) private var logManager
    /// extracts the `AppState` type variable that was passed as an environment(`object`)
    @Environment(AppState.self) private var rootAppState
    @Environment(UserManager.self) private var userManager
    var selectedColor: Color = .accentColor

    @State private var isLoadingToSetupProfile: Bool = false
    @State private var alert: AnyAppAlert?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Setup Completed! 🎉")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectedColor)

            Text("We've set up your profile and you're ready to start chatting")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .screenAppearAnalytics(viewName: "OnboardingCompletedView")
        .safeAreaInset(edge: .bottom) {
            AsyncCallToActionButton(title: "Finish", buttonColor: selectedColor, conditionToLoad: $isLoadingToSetupProfile) {
                onFinishButtonPressed()
            }
        }
        .showCustomAlert(alert: $alert)
        .padding(16)
    }
}

// MARK: - Seperate Business Logic out of Views
extension OnboardingCompletedView {
    private func onFinishButtonPressed() {
        let hex = selectedColor.toHex()
        logManager.trackEvent(event: OnboardingCompletedViewEvent.finishStart(colorHex: hex))
        isLoadingToSetupProfile = true

        Task {
            defer { isLoadingToSetupProfile = false }
            do {
                try await userManager.markOnboardingAsCompleted(profileColorHex: hex)
                logManager.trackEvent(event: OnboardingCompletedViewEvent.finishSuccess(colorHex: hex))
                rootAppState.updateViewState(showTabBar: true)
            } catch {
                logManager.trackEvent(event: OnboardingCompletedViewEvent.finishFail(error: error))
                alert = AnyAppAlert(error: error)
            }
        }
    }
}

extension OnboardingCompletedView {
    enum OnboardingCompletedViewEvent: LoggableEvent {
        case finishStart(colorHex: String)
        case finishSuccess(colorHex: String)
        case finishFail(error: Error)

        var eventName: String {
            switch self {
            case .finishStart:
                return "OnboardingCompletedView_Finish_Start"
            case .finishSuccess:
                return "OnboardingCompletedView_Finish_Success"
            case .finishFail:
                return "OnboardingCompletedView_Finish_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .finishStart(colorHex: let hex),
                 .finishSuccess(colorHex: let hex):
                return hex.asEventParameter(key: "profile_color_hex")
            case .finishFail(error: let error):
                return error.asEventParameter
            }
        }

        var type: LogType {
            switch self {
            case .finishFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(LogManager(services: [ConsoleService()]))
        .environment(UserManager(services: MockUserServicesContainer(user: .mock)))
        .environment(AppState())
}
