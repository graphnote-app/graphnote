//
//  LabelPalette.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/27/23.
//

import SwiftUI

enum LabelPalette: String {
    case primary, purple, red, lightPurple, pink, limeGreen, darkOrange, lightOrange
    
    func getColor() -> Color {
        switch self {
        case .primary:
            return LabelColor.primary
        case .purple:
            return LabelColor.purple
        case .red:
            return LabelColor.red
        case .lightPurple:
            return LabelColor.lightPurple
        case .pink:
            return LabelColor.pink
        case .limeGreen:
            return LabelColor.limeGreen
        case .darkOrange:
            return LabelColor.darkOrange
        case .lightOrange:
            return LabelColor.lightOrange
        }
    }
    
    static func allCases() -> [LabelPalette] {
        return [primary, purple, red, lightPurple, pink, limeGreen, darkOrange, lightOrange]
    }
}
