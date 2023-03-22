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
        ScrollView {
            HStack(spacing: Spacing.spacing0.rawValue) {
                VStack(alignment: .leading) {
                    ForEach(0..<items.count, id: \.self) { i in
                        TreeViewLabel(id: UUID(), label: .constant(items[i].title), color: items[i].color) {
                            ForEach(items[i].subItems, id: \.id) { subItem in
                                TreeViewSubline(title: subItem.title)
                                    .padding(Spacing.spacing2.rawValue)
                            }
                        }
                    }
                }
                Spacer()
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
