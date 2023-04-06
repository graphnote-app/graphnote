//
//  SignInView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI
import AuthenticationServices

enum SignInError: LocalizedError {
    case signInNoUser
    
    var errorDescription: String? {
        switch self {
        case .signInNoUser:
            return "There was an issue signing you in.. Please make sure you are connected to the internet. Contact us for support if the issue continues!"
        }
    }
}

struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme

    let callback: () -> Void
    
    @State private var welcomeOpacity = 0.0
    @State private var getStartedOpacity = 0.0
    @State private var signInButtonOpacity = 0.0
    @State private var imageSizeScaler = 0.25
    @State private var isFailureAlertOpen = false
    
    private let duration = 2.0
    private let imageWidth = 140.0
    private let authService: AuthService
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
        self.authService = AuthService()
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                SignInWithAppleButton { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        authService.process(authorization: authorization, callback: { success in
                            if success {
                                callback()
                            } else {
                                isFailureAlertOpen = true
                                callback()
                            }
                        })

                    case .failure(let error):
                        print(error)
                    }
                }
                .frame(width: 220, height: 40)
                .opacity(signInButtonOpacity)
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .ignoresSafeArea()
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
        }
        .alert(isPresented: $isFailureAlertOpen, error: SignInError.signInNoUser, actions: {
            
        })
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
