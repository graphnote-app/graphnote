//
//  Constants.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/26/22.
//

import Foundation
import SwiftUI

#if os(macOS)
let darkBackgroundColor = Color(NSColor.controlBackgroundColor)
#else
let darkBackgroundColor = Color(red: 30 / 255.0, green: 30 / 255.0, blue: 30 / 255.0, opacity: 1.0)
#endif

let lightBackgroundColor = Color.white

let treeWidth: CGFloat = 250
let mobileTreeWidth: CGFloat = 275
