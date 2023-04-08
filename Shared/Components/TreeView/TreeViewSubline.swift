//
//  TreeViewSubline.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/21/23.
//

import SwiftUI

struct TreeViewSubline: View {
    let title: String
    let selected: Bool
    
    var body: some View {
        HStack {
            TreeDocView()
            HStack {
                Text(title)
                Spacer()
            }.frame(width: 130)
        }
        .padding(Spacing.spacing2.rawValue)
        .background(selected ? Color.gray.opacity(0.25) : .clear)
        .cornerRadius(Spacing.spacing2.rawValue)
        .contentShape(RoundedRectangle(cornerRadius: Spacing.spacing2.rawValue))
        
    }
}

struct TreeViewSubLine_Previews: PreviewProvider {
    static var previews: some View {
        TreeViewSubline(title: "Test preview", selected: false)
    }
}
