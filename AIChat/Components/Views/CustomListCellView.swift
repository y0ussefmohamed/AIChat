//
//  CustomListCellView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 08/03/2026.
//

import SwiftUI

struct CustomListCellView: View {
    var avatarName: String? = "Alpha"
    var avatarDescription: String? = "A cat that is smiling in the park."
    var imageName: String? = Constants.randomImage

    var body: some View {
        HStack {
            ZStack {
                if let imageName {
                    ImageLoaderView(imageUrlString: imageName)

                } else {
                    Rectangle()
                        .fill(.secondary)
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 60)
            .cornerRadius(16)


            if let avatarName {
                VStack(alignment: .leading) {
                    Text(avatarName)
                        .font(.headline)

                    if let avatarDescription {
                        Text(avatarDescription)
                            .font(.subheadline)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background()
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        
        VStack {
            CustomListCellView()
            CustomListCellView(imageName: nil)
        }
    }
}
