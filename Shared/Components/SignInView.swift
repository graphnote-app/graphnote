//
//  SignInView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var uiState: AppGlobalUIState
    
    @State private var welcomeOpacity = 0.0
    @State private var getStartedOpacity = 0.0
    @State private var signInButtonOpacity = 0.0
    @State private var imageSizeScaler = 0.25
    private let duration = 2.0
    private let imageWidth = 140.0
    private let authService = AuthService()
    
    func content(geometry: GeometryProxy) -> some View {
        VStack(spacing: Spacing.spacing6.rawValue) {
            Group {
                Spacer()
                Spacer()
            }
            VStack {
                Image("GraphnoteIcon")
                    .resizable()
                    .opacity(imageSizeScaler)
                    .frame(width: imageWidth * imageSizeScaler, height: imageWidth * imageSizeScaler)
            }.frame(width: imageWidth, height: imageWidth)
            Text("\"Augment your memory\"")
                .font(.title3)
                .opacity(welcomeOpacity)
            Group {
                Spacer()
                Spacer()
            }
            Text("Welcome to Graphnote")
                .font(.system(size: Spacing.spacing7.rawValue))
                .foregroundColor(LabelColor.primary)
                .opacity(welcomeOpacity)
            Text("Thanks for using Graphnote. Built in Tennessee with Love.")
                .font(.body)
                .multilineTextAlignment(.center)
                .opacity(welcomeOpacity)
            Spacer()
                .frame(height: Spacing.spacing6.rawValue)
            Text("Sign in to get started.")
                .font(.title2)
                .opacity(getStartedOpacity)
            #if os(macOS)
            AppleSignInButton()
                .frame(width: 200, height: 80)
                .opacity(signInButtonOpacity)
                .disabled(true)
            #else
            AppleSignInButton()
                .frame(width: 220, height: 40)
                .opacity(signInButtonOpacity)
                .onTapGesture {
                    authService.handleAuthorizationAppleIDButtonPress { success in
                        if success {
                            withAnimation {
                                uiState = .doc
                            }
                        }
                    }
                }
            #endif
            Spacer()
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .ignoresSafeArea()
        .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            #if os(macOS)
            content(geometry: geometry)
            .onTapGesture {
                authService.handleAuthorizationAppleIDButtonPress { success in
                    if success {
                        withAnimation {
                            uiState = .doc
                        }
                    }
                }
            }
            #else
            content(geometry: geometry)
            #endif
        }
        
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                imageSizeScaler = 1.0
            }
            
            withAnimation(.easeOut(duration: duration).delay(1)) {
                welcomeOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: duration).delay(1 + duration / 2)) {
                getStartedOpacity = 1.0
                signInButtonOpacity = 1.0
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(uiState: .constant(AppGlobalUIState.doc))
    }
}
