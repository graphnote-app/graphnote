//
//  AppMacOS.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI
import FirebaseCore

@main
struct AppMacOS: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: GlobalDimension.windowMinimumWidth, minHeight: GlobalDimension.windowMinimumHeight)
        }
        .defaultSize(width: GlobalDimension.windowDefaultWidth, height: GlobalDimension.windowDefaultHeight)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
    }
}
