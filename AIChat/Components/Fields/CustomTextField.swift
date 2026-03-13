//
//  CustomTextField.swift
//  AIChat
//
//  Created by Youssef Mohamed on 11/03/2026.
//

import Foundation
import SwiftUI

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String?

    var body: some View {
        HStack {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
            }

            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
