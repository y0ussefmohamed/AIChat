//
//  AsyncCallToActionButton.swift
//  AIChat
//
//  Created by Youssef Mohamed on 12/03/2026.
//

import SwiftUI

struct AsyncCallToActionButton: View {
    var title: String
    var buttonColor: Color?
    @Binding var conditionToLoad: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if conditionToLoad {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                }
            }
            .callToActionButton(buttonColor: buttonColor ?? .accent)
        }
        .disabled(conditionToLoad)
        .opacity(conditionToLoad ? 0.6 : 1.0)
    }
}

#Preview {
    @State @Previewable var conditionToLoad: Bool = false
    
    AsyncCallToActionButton(title: "Save", conditionToLoad: $conditionToLoad, action: {
        Task {
            conditionToLoad = true
            try? await Task.sleep(for: .seconds(2))
            conditionToLoad = false
        }
    })
    .padding()
}
