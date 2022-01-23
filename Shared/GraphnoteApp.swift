//
//  GraphnoteApp.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

fileprivate enum MacOSDimensions: CGFloat {
    case windowMinWidth = 1138
    case windowMinHeight = 600
}

@main
struct GraphnoteApp: App {
    func content() -> some View {
        #if os(macOS)
        GeometryReader { geometry in
            ContentView()
                .toolbar {
                    ToolbarItem {
                        Text("")
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
    
    var body: some Scene {
        #if os(macOS)
        WindowGroup() {
            content()
        }.windowToolbarStyle(.unifiedCompact)
            
        #else
        WindowGroup {
            content()
        }
        #endif
    }
}
