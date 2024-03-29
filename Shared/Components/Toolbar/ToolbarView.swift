//
//  ToolbarView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct ToolbarView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let content: () -> any View
    let action: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            AnyView(content())
                .padding(Spacing.spacing3.rawValue)
                .onTapGesture(perform: action)
        }
        .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView {
            MenuCardView()
        } action: {
            
        }
    }
}
