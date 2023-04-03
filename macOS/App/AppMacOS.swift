//
//  AppMacOS.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

let seed = false

@main
struct AppMacOS: App {
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
