//
//  ContentView.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData
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

let treeWidth: CGFloat = 250
let mobileTreeWidth: CGFloat = 275
fileprivate let documentWidth: CGFloat = 800
fileprivate let treeLayourPriority: CGFloat = 100

let jsonString = "[{\"id\":\"123\", \"title\": \"Kanception\", \"documents\": [{\"id\": \"321\", \"title\": \"Design Doc\", \"selected\": false}]}, {\"id\":\"234\", \"title\": \"Graphnote\", \"documents\": [{\"id\": \"432\", \"title\": \"Project Kickoff\", \"selected\": false}]},{\"id\":\"345\", \"title\": \"SwiftBook\", \"documents\": [{\"id\": \"543\", \"title\": \"MVP\", \"selected\": false}]},{\"id\":\"456\", \"title\": \"DarkTorch\", \"documents\": [{\"id\": \"543\", \"title\": \"Design Doc\", \"selected\": false}]},]"


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    let moc: NSManagedObjectContext
    @State private var selected: (workspaceId: String, documentId: String) = ("", "")
    @State private var open: Bool = true
    @FetchRequest var workspaces: FetchedResults<Workspace>
    
    var data: [TreeDatum] = []

    init(moc: NSManagedObjectContext) {
        self.moc = moc
        
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
        
        self._workspaces = FetchRequest(
            entity: Workspace.entity(),
            sortDescriptors: [
                
            ]
        )
        
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workspace.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        try! self.moc.execute(deleteRequest)

//        let workspace = Workspace(context: moc)
//        workspace.id = UUID()
//        workspace.title = "Graphnote"
//
//        try! moc.save()
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
                    ForEach(self.workspaces) { workspace in
                        Text(workspace.title!)
                        
                    }
//                    TreeView(items: items) { treeViewItemId, documentId in
//                        selected = (treeViewItemId, documentId)
//                    }
//                        .padding()
                       
                }
                .frame(width: treeWidth)
                .edgesIgnoringSafeArea([.bottom])
                #else
                ZStack() {
                    EffectView()
                    TreeView(items: items) { treeViewItemId, documentId in
                        selected = (treeViewItemId, documentId)
                    }
                        .layoutPriority(treeLayourPriority)
                        
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
