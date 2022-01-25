//
//  GraphnoteApp.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import CoreData
import SwiftUI

fileprivate enum MacOSDimensions: CGFloat {
    case windowMinWidth = 1038
    case windowMinHeight = 600
}

@main
struct GraphnoteApp: App {
    @StateObject private var dataController = DataController()
    
    func content() -> some View {
        #if os(macOS)
        GeometryReader { geometry in
            ContentView(moc: dataController.container.viewContext)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(OrientationInfo())
        }.frame(
            minWidth: MacOSDimensions.windowMinWidth.rawValue,
            idealWidth: MacOSDimensions.windowMinWidth.rawValue,
            minHeight: MacOSDimensions.windowMinHeight.rawValue,
            idealHeight: MacOSDimensions.windowMinHeight.rawValue
        )
        #else
        GeometryReader { geometry in
            ContentView(moc: dataController.container.viewContext)
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(OrientationInfo())
        }
        #endif
    }
    
    var body: some Scene {
        #if os(macOS)
        WindowGroup() {
            content()
                
        }
        .windowToolbarStyle(.unifiedCompact)
        .windowStyle(.hiddenTitleBar)
            
        #else
        WindowGroup {
            content()
                
        }
        #endif
    }
}
