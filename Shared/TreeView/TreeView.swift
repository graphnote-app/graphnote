//
//  TreeView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

final class TreeViewModel: ObservableObject {
    @Published public var closure: (_ treeViewItemId: String, _ documentId: String) -> ()
    
    init(closure: @escaping (_ treeViewItemId: String, _ documentId: String) -> ()) {
        self.closure = closure
    }
}

struct TreeView: View {
    let items: [TreeViewItem]
    let closure: (_ treeViewItemId: String, _ documentId: String) -> ()
    
    var body: some View {
        ZStack {
            EffectView()
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(alignment: .leading) {
                    ForEach(items) { item in
                        item.environmentObject(TreeViewModel(closure: closure))
                    }
                    
                }
                .padding()
            }
        }
    }
}


struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        let items = [
            TreeViewItem(id: "123", title: "Kanception", documents: [Title(id: "123", value: "Title 1", selected: false), Title(id: "321", value: "Title 2", selected: false)]),
            TreeViewItem(id: "234", title: "Graphnote", documents: [Title(id: "123", value: "Title 1", selected: false), Title(id: "321", value: "Title 2", selected: false)]),
            TreeViewItem(id: "345", title: "SwiftBook", documents: [Title(id: "123", value: "Title 1", selected: true), Title(id: "321", value: "Title 2", selected: false)]),
        ]
        TreeView(items: items) { treeViewItem, documentId in
            
        }
    }
}