//
//  SignInWithAppleButtonView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI
import AuthenticationServices

#if os(macOS)
struct AppleSignInButton: NSViewRepresentable {
    typealias NSViewType = ASAuthorizationAppleIDButton
    
    private let authService = AuthService()
    
    func makeNSView(context: Context) -> NSViewType {
        let authButton = ASAuthorizationAppleIDButton()
        authButton.action = #selector(authService.handleAuthorizationAppleIDButtonPress)
        return authButton
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
}

#else
struct AppleSignInButton: UIViewRepresentable {
    typealias UIViewType = ASAuthorizationAppleIDButton
    
    private let authService = AuthService()
    
    func makeUIView(context: Context) -> UIViewType {
        let authButton = ASAuthorizationAppleIDButton()
        authButton.addTarget(self, action: #selector(authService.handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        return authButton
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}
#endif
