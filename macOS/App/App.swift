//
//  App.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

let reseed = false

@main
struct GNApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.isSeeding, reseed)
        }
        .defaultSize(width: GlobalDimension.windowDefaultWidth, height: GlobalDimension.windowDefaultHeight)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
    }
}
