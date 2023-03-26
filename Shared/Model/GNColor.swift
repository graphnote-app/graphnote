//
//  GNColor.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import SwiftUI

struct GNColor {
    let id: UUID
    let name: String
    let createdAt: Date
    let modifiedAt: Date
    let r: Float
    let g: Float
    let b: Float
    
    func getSwiftUIColor() -> Color {
        return Color(red: Double(self.r), green: Double(self.g), blue: Double(self.b))
    }
}

