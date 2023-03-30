//
//  EmptyBlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/11/23.
//

import SwiftUI

struct EmptyBlockView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Rectangle()
            .foregroundColor(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
            .frame(height: Spacing.spacing7.rawValue)
            .contentShape(Rectangle())
    }
}
