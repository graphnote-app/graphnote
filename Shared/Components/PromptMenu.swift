//
//  PromptMenu.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/23/23.
//

import SwiftUI

struct PromptMenu: View {
    let onAddContentLink: () -> Void
    
    var body: some View {
        List() {
            Button("Add content link") {
                onAddContentLink()
            }
            .buttonStyle(.borderless)
        }
        .shadow(radius: Spacing.spacing6.rawValue)
        .frame(width: GlobalDimension.treeWidth, height: 400)
        .zIndex(2)
    }
}

struct PromptMenu_Previews: PreviewProvider {
    static var previews: some View {
        PromptMenu {
            
        }
    }
}
