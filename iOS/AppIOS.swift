//
//  AppIOS.swift
//  Graphnote (iOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import SwiftUI
import FirebaseCore

@main
struct AppIOS: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .autocorrectionDisabled()
                .keyboardType(.alphabet)
                .scrollDismissesKeyboard(.interactively)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
