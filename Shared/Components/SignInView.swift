//
//  SignInView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

enum SignInError: LocalizedError {
    case signInNoUser
    case createUserFailed
    case fetchFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .signInNoUser:
            return "There was an issue signing you in.. Please make sure you are connected to the internet. Contact us for support if the issue continues!"
        case .createUserFailed:
            return "There was an issue signing you in.. (Failed to create user)"
        case .fetchFailed:
            return "There was an issue signing you in.. (Failed to fetch user)"
        case .unknown:
            return "There was an issue signing you in.. (Failed for unknown reason)"
        }
    }
}

struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme

    let callback: (_ isSignUp: Bool, _ user: User?, _ success: Bool) -> Void
    
    @State private var welcomeOpacity = 0.0
    @State private var getStartedOpacity = 0.0
    @State private var signInButtonOpacity = 0.0
    @State private var imageSizeScaler = 0.25
    @State private var isFailureAlertOpen = false
    @State private var isFailureAlertMessage: SignInError? = nil
    @State private var currentNonce: String? = nil
    
    private let duration = 2.0
    private let imageWidth = 140.0
    private let authService = AuthService()
    
    init(callback: @escaping (_ isSignUp: Bool, _ user: User?, _ success: Bool) -> Void) {
        self.callback = callback
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }

        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
        }.joined()

        return hashString
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
                    currentNonce = randomNonceString()
                    guard let nonce = currentNonce else  {
                        return
                    }
                    
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        guard let nonce = currentNonce else {
                            #if DEBUG
                            fatalError()
                            #endif
                            return
                        }
                        
                        authService.process(authorization: authorization, currentNonce: nonce, callback: { isSignUp, user, error in
                            if let error {
                                switch error {
                                case .createUserFailed:
                                    isFailureAlertMessage = SignInError.createUserFailed
                                case .fetchFailed:
                                    isFailureAlertMessage = SignInError.fetchFailed
                                case .userNotFound:
                                    isFailureAlertMessage = SignInError.signInNoUser
                                case .unknown:
                                    isFailureAlertMessage = SignInError.unknown
                                }
                                print(error)

                                isFailureAlertOpen = true
                                callback(isSignUp, nil, false)
                            }

                            callback(isSignUp, user, true)

                        })

                    case .failure(let error):
                        print(error)
                        callback(false, nil, false)
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
        .alert(isPresented: $isFailureAlertOpen, error: isFailureAlertMessage, actions: {
            Text("OK")
                .onTapGesture {
                    isFailureAlertMessage = nil
                }
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
