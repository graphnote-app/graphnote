//
//  SignInWithAppleButtonView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI
import AuthenticationServices

#if os(macOS)

final class GNAuthorizationAppleIDButton: ASAuthorizationAppleIDButton {
    init(callback: @escaping (Bool) -> Void) {
        self.callback = callback
        
        super.init(authorizationButtonType: .default, authorizationButtonStyle: .black)
        self.target = self
        self.action = #selector(handleAction)
    }
    
    let callback: (Bool) -> Void
    
    private let authService = AuthService()
    
    @objc
    func handleAction() {
        authService.handleAuthorizationAppleIDButtonPress(callback: callback)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct AppleSignInButton: NSViewRepresentable {
    typealias NSViewType = GNAuthorizationAppleIDButton
    
    let callback: (Bool) -> Void
    
    func makeNSView(context: Context) -> NSViewType {
        return GNAuthorizationAppleIDButton(callback: callback)
    }
    
    func updateNSView(_ nsView: GNAuthorizationAppleIDButton, context: Context) {

    }
}

#else
struct AppleSignInButton: UIViewRepresentable {
    typealias UIViewType = ASAuthorizationAppleIDButton
    
    func makeUIView(context: Context) -> UIViewType {
        return ASAuthorizationAppleIDButton()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}
#endif
