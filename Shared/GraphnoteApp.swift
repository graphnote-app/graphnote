//
//  GraphnoteApp.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

@main
struct GraphnoteApp: App {
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ContentView()
                    .toolbar {
                        Text("")
                    }
            }
        }
    }
}
