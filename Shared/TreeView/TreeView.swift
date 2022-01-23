//
//  TreeView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

struct TreeView: View {
    let items: [TreeViewItem]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(items) { item in
                    item
                }
            }
            .padding()
        }
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        let items = [
            TreeViewItem(id: "123", title: "Kanception", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "234", title: "Graphnote", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "345", title: "SwiftBook", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "456", title: "Fragment", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "567", title: "DarkTorch", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "678", title: "Calcify", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "789", title: "Kanception", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "890", title: "Graphnote", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "412", title: "SwiftBook", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "346", title: "Fragment", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "7432", title: "DarkTorch", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "4324", title: "Calcify", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
        ]
        TreeView(items: items)
    }
}
