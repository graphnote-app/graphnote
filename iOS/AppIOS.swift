//
//  AppIOS.swift
//  Graphnote (iOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import SwiftUI

@main
struct AppIOS: App {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .autocorrectionDisabled()
                .keyboardType(.alphabet)
                .scrollDismissesKeyboard(.interactively)
        }
    }
}
