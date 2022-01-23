//
//  TreeView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

struct TreeView: View {
    var body: some View {
        
        ScrollView(.vertical) {
            VStack {
                VStack(alignment: .leading) {
                    TreeViewItem(title: "Kanception", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "Graphnote", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "SwiftBook", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "Fragment", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "DarkTorch", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "Calcify", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                }
                VStack(alignment: .leading) {
                    TreeViewItem(title: "Kanception", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "Graphnote", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "SwiftBook", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "Fragment", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "DarkTorch", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                    TreeViewItem(title: "Calcify", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
                }
            }
            .padding()
        }
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        TreeView()
    }
}
