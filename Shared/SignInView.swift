//
//  SignInView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var welcomeOpacity = 0.0
    @State private var getStartedOpacity = 0.0
    @State private var imageSizeScaler = 0.25
    private let duration = 2.0
    private let imageWidth = 140.0
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: Spacing.spacing6.rawValue) {
                Spacer()
                VStack {
                    Image("GraphnoteIcon")
                        .resizable()
                        .opacity(imageSizeScaler)
                        .frame(width: imageWidth * imageSizeScaler, height: imageWidth * imageSizeScaler)
                }.frame(width: imageWidth, height: imageWidth)
                
                Spacer()
                Text("Welcome to Graphnote")
                    .font(.largeTitle)
                    .opacity(welcomeOpacity)
                Text("Sign in to get started.")
                    .font(.title2)
                    .opacity(getStartedOpacity)
                #if os(macOS)
                AppleSignInButton()
                    .frame(width: 200, height: 80)
                #else
                AppleSignInButton()
                    .frame(width: 220, height: 60)
                #endif
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .ignoresSafeArea()
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
        }
        
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                imageSizeScaler = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeOut(duration: duration)) {
                    welcomeOpacity = 1.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
                    withAnimation(.easeOut(duration: duration)) {
                        getStartedOpacity = 1.0
                    }
                }
            }
            
            
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
