//
//  TreeViewSubline.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/21/23.
//

import SwiftUI

struct TreeViewSubline: View {
    let title: String
    
    var body: some View {
        HStack {
            TreeBulletView()
            HStack {
                Text(title)
                Spacer()
            }.frame(width: 130)
        }
    }
}

struct TreeViewSubLine_Previews: PreviewProvider {
    static var previews: some View {
        TreeViewSubline(title: "Test preview")
    }
}
