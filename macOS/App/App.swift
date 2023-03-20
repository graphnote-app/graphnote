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
    static let maxDocumentContentWidth = 800.0
    static let minDocumentContentWidth = 400.0
    static let minDocumentContentHeight = 300.0
    static let windowDefaultWidth = 1038.0
    static let windowDefaultHeight = 600.0
}

@main
struct GNApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: GlobalDimension.windowDefaultWidth, height: GlobalDimension.windowDefaultHeight)
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
    }
}
