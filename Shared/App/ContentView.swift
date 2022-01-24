//
//  ContentView.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import SwiftyJSON

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

let jsonString = "[{\"id\":\"123\", \"title\": \"Kanception\", \"documents\": [{\"id\": \"321\", \"title\": \"Design Doc\", \"selected\": false}]}, {\"id\":\"234\", \"title\": \"Graphnote\", \"documents\": [{\"id\": \"432\", \"title\": \"Project Kickoff\", \"selected\": false}]},{\"id\":\"345\", \"title\": \"SwiftBook\", \"documents\": [{\"id\": \"543\", \"title\": \"MVP\", \"selected\": false}]},{\"id\":\"456\", \"title\": \"DarkTorch\", \"documents\": [{\"id\": \"543\", \"title\": \"Design Doc\", \"selected\": false}]},]"


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selected: (workspaceId: String, documentId: String) = ("", "")
    @State private var open: Bool = true
    
    var data: [TreeDatum] = []
    
    init() {
        if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
            if let json = try? JSON(data: dataFromString) {
                data = json.arrayValue.map { row in
                    let id = row["id"].stringValue
                    let title = row["title"].stringValue
                    let documents = row["documents"].arrayValue.map { (id: $0["id"].stringValue, title: $0["title"].stringValue) }
                    return TreeDatum(id: id, title: title, documents: documents)
                }
            }
        }
        
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
