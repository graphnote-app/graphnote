//
//  TreeView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

struct TreeView: View {
    var body: some View {
        VStack(alignment: .leading) {
            TreeViewItem(title: "Testing the tree view", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
            TreeViewItem(title: "Testing the tree view", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
            TreeViewItem(title: "Testing the tree view", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
            TreeViewItem(title: "Testing the tree view", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
            TreeViewItem(title: "Testing the tree view", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
            TreeViewItem(title: "Testing the tree view", documentTitles: [Title(id: "123", value: "Title 1"), Title(id: "321", value: "Title 2")])
        }
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        TreeView()
    }
}
