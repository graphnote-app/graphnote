//
//  SignInWithAppleButtonView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI
import AppKit
import Cocoa

struct AppleSignInButton: NSViewRepresentable {
    typealias NSViewType = NSButton
    
    func makeNSView(context: Context) -> NSViewType {
        return NSButton()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        
    }
}

//import AuthenticationServices

//#if os(macOS)


//#else
//struct SignInWithAppleButton: UIViewRepresentable {
//    func makeUIView(context: Context) -> some UIView {
//        return ASAuthorizationAppleIDButton()
//    }
//
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//
//    }
//}
//#endif
