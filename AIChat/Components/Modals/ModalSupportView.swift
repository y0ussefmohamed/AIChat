//
//  ModalSupportView.swift
//  AIChat
//
//  Created by Youssef Mohamed on 14/03/2026.
//

import SwiftUI

/// This View is used to show a background behind the Generic modal
struct ModalSupportView<Content: View>: View {
    @Binding var showProfileModal: Bool
    @ViewBuilder var modalContent: Content

    var body: some View {
        ZStack {
            if showProfileModal {
                Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                    .transition(AnyTransition.opacity.animation(.easeInOut))
                    .onTapGesture {
                        showProfileModal = false
                    }
                    .zIndex(1)

                modalContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(2)
            }
        }
        .zIndex(999)
        .animation(.smooth, value: showProfileModal)
    }
}

private struct PreviewView: View {
    @State var showProfileModal: Bool = false

    var body: some View {

        ZStack {
            Button("Show Modal") {
                showProfileModal.toggle()
            }

            ModalSupportView(showProfileModal: $showProfileModal, modalContent: { Text("Hello")
            })
        }
        .showModal(
            isPresented: $showProfileModal,
            content: { /// this will be the modalContent inside the `ModalSupportView`
                ZStack {
                    let avatar = Avatar.mocks[2]
                    ProfileModalView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subtitle: avatar.characterOption?.rawValue,
                        onXMarkPressed: {
                            showProfileModal.toggle()
                        }
                    )
                }
            },
            transition: .slide
        )
    }
}

#Preview {
    PreviewView()
}
