//
//  App.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct GlobalDimension {
    static let treeWidth: CGFloat = 250
}

@main
struct GNApp: App {
    var body: some Scene {
        WindowGroup {
            SplitView {
                Rectangle()
                    .frame(width: GlobalDimension.treeWidth)
            } detail: {
                Rectangle()
            }
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
    }
}
