//
//  ColorPalette.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/23/23.
//

import SwiftUI

struct ColorPalette {
    #if os(macOS)
    static let darkBG1 = Color(NSColor.controlBackgroundColor)
    #else
    static let darkBG1 = Color(red: 30 / 255.0, green: 30 / 255.0, blue: 30 / 255.0)
    #endif
    
    static let lightBG1 = Color.white
    
    static let primaryText = Color.primary
}
