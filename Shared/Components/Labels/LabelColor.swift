//
//  LabelColor.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import Foundation
import SwiftUI

// primary: 5E81FF
// purple: #8B5EFF
// red: #FF5E81
// lightPurple: #FF5ED2
// pink: #FF7581
// limeGreen: #5EFF8B
// darkOrange: #FF9881
// lightOrange: FFC962

struct LabelColor {
    static let primary = Color(red: 94.0 / 255.0, green: 129.0 / 255.0, blue: 255.0 / 255.0)
    static let purple = Color(red: 139.0 / 255.0, green: 94.0 / 255.0, blue: 255.0 / 255.0)
    static let red = Color(red: 255.0 / 255.0, green: 94.0 / 255.0, blue: 129.0 / 255.0)
    static let lightPurple = Color(red: 255.0 / 255.0, green: 94.0 / 255.0, blue: 210.0 / 255.0)
    static let pink = Color(red: 255.0 / 255.0, green: 117.0 / 255.0, blue: 179.0 / 255.0)
    static let limeGreen = Color(red: 94.0 / 255.0, green: 255.0 / 255.0, blue: 139.0 / 255.0)
    static let darkOrange = Color(red: 255.0 / 255.0, green: 152.0 / 255.0, blue: 129.0 / 255.0)
    static let lightOrange = Color(red: 255.0 / 255.0, green: 201.0 / 255.0, blue: 98.0 / 255.0)
    
    static let allColors: [SwiftUI.Color] = [
        LabelColor.primary,
        LabelColor.purple,
        LabelColor.red,
        LabelColor.lightPurple,
        LabelColor.pink,
        LabelColor.limeGreen,
        LabelColor.darkOrange,
        LabelColor.lightOrange,
    ]
}
