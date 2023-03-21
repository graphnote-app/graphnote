//
//  TreeView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct TreeView: View {
    var items: [TreeViewItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<items.count, id: \.self) { i in
                TreeViewLabel(id: UUID(), label: .constant(items[i].title), color: items[i].color) {
                    ForEach(items[i].subItems, id: \.id) { subItem in
                        TreeViewSubline(title: subItem.title)
                    }
                }
            }
            TreeViewLabel(id: UUID(), label: .constant("ALL"), color: .gray) {
                EmptyView()
            }
        }
        .padding([.top, .bottom])
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        TreeView(items: [])
    }
}
