//
//  LabelPalette.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/27/23.
//

import SwiftUI

enum LabelPalette: String {
    case primary, purple, pink, orangeDark, orangeLight, yellow
    
    func getColor() -> Color {
        switch self {
        case .primary:
            return LabelColor.primary
        case .purple:
            return LabelColor.purple
        case .pink:
            return LabelColor.pink
        case .orangeDark:
            return LabelColor.orangeDark
        case .orangeLight:
            return LabelColor.orangeLight
        case .yellow:
            return LabelColor.yellow
        }
    }
    
    static func allCases() -> [LabelPalette] {
        return [primary, purple, pink, orangeDark, orangeLight, yellow]
    }
}
