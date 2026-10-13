//
//  DevSettingsView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/08/2026.
//

import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: DevSettingsViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("CreateAccountTest", isOn: $viewModel.createAccountTest)
                        .accessibilityIdentifier(AccessibilityID.DeveloperSettings.createAccount)
                        .onChange(of: viewModel.createAccountTest) { _, newValue in
                            viewModel.updateCreateAccountTest(to: newValue)
                        }

                    Toggle("OnboardingCommunityTest", isOn: $viewModel.onboardingCommunityTest)
                        .accessibilityIdentifier(AccessibilityID.DeveloperSettings.community)
                        .onChange(of: viewModel.onboardingCommunityTest) { _, newValue in
                            viewModel.updateOnboardingCommunityTest(to: newValue)
                        }

                    Picker("CategoryRowTest", selection: $viewModel.categoryRowTest) {
                        ForEach(CategoryRowTestOption.allCases, id: \.self) { option in
                            Text(option.rawValue.capitalized)
                                .accessibilityIdentifier(AccessibilityID.DeveloperSettings.categoryOption(option.rawValue))
                                .tag(option)
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.DeveloperSettings.categoryRow)
                    .accessibilityValue(viewModel.categoryRowTest.rawValue)
                    .onChange(of: viewModel.categoryRowTest) { _, newValue in
                        viewModel.updateCategoryRowTest(to: newValue)
                    }
                } header: {
                    Text("AB Test Section")
                }
                .disabled(!viewModel.canOverrideTests)

                Section {
                    ForEach(viewModel.authInfo, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Auth Info")
                }

                Section {
                    ForEach(viewModel.currentUserInfo, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Current User Info")
                }

                Section {
                    ForEach(viewModel.deviceInfo, id: \.key) { item in
                        itemRow(item: item)
                    }
                } header: {
                    Text("Device Info")
                }
            }
            .accessibilityIdentifier(AccessibilityID.DeveloperSettings.list)
            .screenAppearAnalytics(viewName: "DevSettingsView")
            .navigationTitle("Dev Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Image(systemName: "xmark")
                        .styledButton {
                            viewModel.onCloseButtonPressed {
                                dismiss()
                            }
                        }
                        .accessibilityLabel("Close developer settings")
                        .accessibilityIdentifier(AccessibilityID.DeveloperSettings.close)
                }
            }
            .onFirstAppear {
                viewModel.loadActiveTests()
            }
            .showCustomAlert(alert: $viewModel.alert)
        }
    }
}

private extension DevSettingsView {
    func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)

            Spacer()

            if let value = item.value as? String {
                if value.hasPrefix("#"),
                   let color = Color(hex: value) {
                    Circle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                } else if let convertedValue = String.convertToString(item.value) {
                    Text(convertedValue)
                }
            }
        }
    }
}

#Preview {
    DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .environment(LogManager(services: [ConsoleService()]))
        .previewEnvironment()
}
