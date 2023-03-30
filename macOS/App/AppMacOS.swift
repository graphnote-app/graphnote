//
//  AppMacOS.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

let seed = true

@main
struct AppMacOS: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: GlobalDimension.windowDefaultWidth, height: GlobalDimension.windowDefaultHeight)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
    }
}
