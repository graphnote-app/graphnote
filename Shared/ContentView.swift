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

let lightTreeColor = Color(red: 248 / 255.0, green: 238 / 255.0, blue: 248 / 255.0, opacity: 1.0)

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selected: (workspaceId: String, documentId: String) = ("", "")
    
    let data = [
        TreeDatum(id: "123", title: "Kanception", documents: [(id: "123", title: "Title 1"), (id: "123321", title: "Title 123")]),
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
            #if os(macOS)
            TreeView(items: items) { treeViewItemId, documentId in
                print("\(treeViewItemId) \(documentId)")
                selected = (treeViewItemId, documentId)
            }
                .padding()
                .layoutPriority(100)
            #else
            
            TreeView(items: items) { treeViewItemId, documentId in
                print("\(treeViewItemId) \(documentId)")
                selected = (treeViewItemId, documentId)
            }
                .padding()
                .background(colorScheme == .dark ? .clear : lightTreeColor)
                .layoutPriority(100)
            #endif

            GeometryReader { geometry in
                ScrollView {
                    VStack {
                        Text("Workspace ID: \(selected.workspaceId) Document ID: \(selected.documentId)")
                            .padding(40)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height * 1.3)
                    .background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
                    
                }.background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
