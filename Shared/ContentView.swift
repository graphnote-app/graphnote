//
//  ContentView.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

struct ContentView: View {
    @State private var selected: (String, String) = ("124353", "123")
    
    var body: some View {
        let items = [
            TreeViewItem(id: "124353", title: "Kanception", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "232344", title: "Graphnote", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "342345", title: "SwiftBook", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "4543256", title: "Fragment", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "523467", title: "DarkTorch", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "623478", title: "Calcify", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "122343", title: "Kanception", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
            TreeViewItem(id: "23234", title: "Graphnote", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")]),
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
        HStack(alignment: .top) {
            TreeView(items: items) { treeViewItemId, documentId in
                print("\(treeViewItemId) \(documentId)")
                selected = (treeViewItemId, documentId)
            }.padding()
                .layoutPriority(100)
            Text("Workspace ID: \(selected.0) Document ID: \(selected.1)")
                .padding(40)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
