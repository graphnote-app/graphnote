//
//  App.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct GlobalDimension {
    static let treeWidth: CGFloat = 250
    static let toolbarWidth = Spacing.spacing4.rawValue + (Spacing.spacing3.rawValue * 2)
}

@main
struct GNApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
    }
}
