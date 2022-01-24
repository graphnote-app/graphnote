//
//  ContentView.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

struct TreeDatum {
    let id: String
    let title: String
    let documents: [(id: String, title: String)]
}

#if os(macOS)
let darkBackgroundColor = Color(NSColor.controlBackgroundColor)
#else
let darkBackgroundColor = Color(red: 30 / 255.0, green: 30 / 255.0, blue: 30 / 255.0, opacity: 1.0)
#endif

let lightBackgroundColor = Color.white
let lightTreeColor = Color(red: 237 / 255.0, green: 235 / 255.0, blue: 240 / 255.0, opacity: 1.0)

let treeWidth: CGFloat = 250
let mobileTreeWidth: CGFloat = 275
fileprivate let documentWidth: CGFloat = 800
fileprivate let treeLayourPriority: CGFloat = 100

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selected: (workspaceId: String, documentId: String) = ("", "")
    @State private var open: Bool = true
    
    let data = [
        TreeDatum(id: "123", title: "Kanception", documents: [(id: "123", title: "Title 1"), (id: "12312312312312312312321", title: "Title 123")]),
        TreeDatum(id: "234", title: "Graphnote", documents: [(id: "234", title: "Title 2"), (id: "1234324", title: "Title 1")]),
        TreeDatum(id: "345", title: "SwiftBook", documents: [(id: "345", title: "Title 3")]),
        TreeDatum(id: "456", title: "DarkTorch", documents: [(id: "456", title: "Title 4")]),
        TreeDatum(id: "123123", title: "Kanception", documents: [(id: "123123", title: "Title 1")]),
        TreeDatum(id: "234234", title: "Graphnote", documents: [(id: "234234", title: "Title 2")]),
        TreeDatum(id: "345345", title: "SwiftBook", documents: [(id: "345345", title: "Title 3")]),
        TreeDatum(id: "456456", title: "DarkTorch", documents: [(id: "456456", title: "Title 4")]),
        TreeDatum(id: "5677", title: "Kanception", documents: [(id: "1231343", title: "Title 1"), (id: "54555", title: "Title 123")]),
        TreeDatum(id: "736", title: "Graphnote", documents: [(id: "123123", title: "Title 2"), (id: "44444", title: "Title 1")]),
        TreeDatum(id: "8678", title: "SwiftBook", documents: [(id: "123131", title: "Title 3")]),
        TreeDatum(id: "345353", title: "DarkTorch", documents: [(id: "234242", title: "Title 4")]),
        TreeDatum(id: "45645647", title: "Kanception", documents: [(id: "3453", title: "Title 1")]),
        TreeDatum(id: "323478", title: "Graphnote", documents: [(id: "4563", title: "Title 2")]),
        TreeDatum(id: "4578843563", title: "SwiftBook", documents: [(id: "7866", title: "Title 3")]),
        TreeDatum(id: "345245", title: "DarkTorch", documents: [(id: "645", title: "Title 4")]),
    ]
    
    init() {
        if let datum = data.first, let documentId = datum.documents.first?.id {
            self._selected = State(initialValue: (workspaceId: datum.id, documentId: documentId))
        }
    }
    
    var body: some View {
        let items = data.map { datum in
            TreeViewItem(
                id: datum.id,
                title: datum.title,
                documents: datum.documents.map { document in
                    Title(
                        id: document.id,
                        value: document.title,
                        selected: datum.id == selected.workspaceId && document.id == selected.documentId
                    )
                }
            )
        }
        
        HStack(alignment: .top) {
            if open {
                #if os(macOS)
                ZStack() {
                    EffectView()
                    TreeView(items: items) { treeViewItemId, documentId in
                        selected = (treeViewItemId, documentId)
                    }
                        .padding()
                        .background(colorScheme == .dark ? .clear : lightTreeColor)
                       
                }.frame(width: treeWidth)
                    .edgesIgnoringSafeArea([.bottom])
                
                #else
                ZStack() {
                    EffectView()
                    TreeView(items: items) { treeViewItemId, documentId in
                        selected = (treeViewItemId, documentId)
                    }
                        .layoutPriority(treeLayourPriority)
                        .background(colorScheme == .dark ? .clear : lightTreeColor)
                        
                }
                .frame(width: mobileTreeWidth)
                .edgesIgnoringSafeArea([.top, .bottom])
                #endif
            }
            

            
            if let datum = data.filter { $0.id == selected.workspaceId }.first, let title = datum.documents.filter { $0.id == selected.documentId }.first?.title  {
                DocumentView(title: title, workspaceTitle: datum.title, selected: selected, open: $open)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
