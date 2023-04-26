//
//  EmptyBlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/11/23.
//

import SwiftUI

struct EmptyBlockView: View {
    @Environment(\.colorScheme) var colorScheme
    let order: Int
    let action: () -> Void
    
    var body: some View {
        Text(String(order))
//            .foregroundColor(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
            .frame(height: Spacing.spacing7.rawValue)
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}
