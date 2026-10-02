//
//  ImageLoaderView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 04/03/2026.
//

import SwiftUI
import SDWebImageSwiftUI

private nonisolated struct ImageURLOverrideKey: EnvironmentKey {
    static let defaultValue: URL? = nil
}

extension EnvironmentValues {
    /// Optional image source supplied by the host, e.g. offline previews or UI-test fixtures.
    var imageURLOverride: URL? {
        get { self[ImageURLOverrideKey.self] }
        set { self[ImageURLOverrideKey.self] = newValue }
    }
}

struct ImageLoaderView: View {
    @Environment(\.imageURLOverride) private var imageURLOverride
    var imageUrlString: String = Constants.randomImage
    // 1. Make the resizing mode Optional. If it's nil, the image will stretch.
    var resizingMode: ContentMode?
    var forceTransitionAnimation: Bool = false
    var alignment: Alignment = .center

    var body: some View {
        Rectangle().opacity(0.001)
            .overlay(alignment: alignment) {
                // 2. Check if a mode was provided
                if let imageURLOverride, let image = UIImage(contentsOfFile: imageURLOverride.path) {
                    if let mode = resizingMode {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: mode)
                            .allowsHitTesting(false)
                    } else {
                        Image(uiImage: image)
                            .resizable()
                            .allowsHitTesting(false)
                    }
                } else if let mode = resizingMode {
                    WebImage(url: imageURLOverride ?? URL(string: imageUrlString))
                        .resizable()
                        .indicator(.activity)
                        .aspectRatio(contentMode: mode) // Protects proportions (fill/fit)
                        .allowsHitTesting(false)
                } else {
                    WebImage(url: imageURLOverride ?? URL(string: imageUrlString))
                        .resizable()
                        .indicator(.activity)
                        // NO aspectRatio modifier here! This forces it to stretch/squash to the frame.
                        .allowsHitTesting(false)
                }
            }
            .clipped()
            .ifSatisfiedCondition(forceTransitionAnimation) { selfContent in
                selfContent
                    .drawingGroup()
            }
    }
}

#Preview {
    ImageLoaderView(resizingMode: nil)
        .frame(width: 300, height: 200)
}
