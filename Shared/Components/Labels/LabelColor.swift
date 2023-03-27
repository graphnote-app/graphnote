//
//  LabelColor.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import Foundation
import SwiftUI

struct LabelColor {
    static let primary = Color(red: 94.0 / 255.0, green: 129.0 / 255.0, blue: 255.0 / 255.0)
    static let purple = Color(red: 225.0 / 255.0, green: 115.0 / 255.0, blue: 226.0 / 255.0)
    static let pink = Color(red: 255.0 / 255.0, green: 117.0 / 255.0, blue: 179.0 / 255.0)
    static let orangeDark = Color(red: 255.0 / 255.0, green: 152.0 / 255.0, blue: 129.0 / 255.0)
    static let orangeLight = Color(red: 255.0 / 255.0, green: 201.0 / 255.0, blue: 98.0 / 255.0)
    static let yellow = Color(red: 249.0 / 255.0, green: 248.0 / 255.0, blue: 113.0 / 255.0)
    
    static let allColors: [SwiftUI.Color] = [
        LabelColor.orangeLight,
        LabelColor.primary,
        LabelColor.pink,
        LabelColor.orangeDark,
        LabelColor.yellow,
        LabelColor.purple
    ]
}
