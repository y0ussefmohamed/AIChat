//
//  RecentsCellView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 15/03/2026.
//

import Foundation
import SwiftUI

struct RecentsCellView: View {
    var imageName: String = Constants.randomImage
    var name: String = "Alpha"

    var body: some View {
        VStack(spacing: 8) {
            ImageLoaderView(imageUrlString: imageName)
                .aspectRatio(contentMode: .fit)
                .clipShape(Circle())

            Text(name)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RecentsCellView()
        .frame(width: 120)
}
