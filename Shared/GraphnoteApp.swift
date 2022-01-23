//
//  GraphnoteApp.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

fileprivate enum MacOSDimensions: CGFloat {
    case windowMinWidth = 1000
    case windowMinHeight = 600
}

@main
struct GraphnoteApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            GeometryReader { geometry in
                ContentView()
                    .toolbar {
                        ToolbarItem {
                        
                        }
                    }
                    
            }.frame(
                minWidth: MacOSDimensions.windowMinWidth.rawValue,
                idealWidth: MacOSDimensions.windowMinWidth.rawValue,
                minHeight: MacOSDimensions.windowMinHeight.rawValue,
                idealHeight: MacOSDimensions.windowMinHeight.rawValue
            )
            #else
            GeometryReader { geometry in
                ContentView()
            }
            #endif
        }
//        .windowToolbarStyle(.unifiedCompact)
    }
}
