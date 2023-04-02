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
    
    func makeNSView(context: Context) -> NSViewType {
        return ASAuthorizationAppleIDButton()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
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
