//
//  ContentView.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData
import SwiftyJSON

fileprivate let documentWidth: CGFloat = 800
fileprivate let treeLayourPriority: CGFloat = 100

//let jsonString = "[{\"id\":\"123\", \"title\": \"Kanception\", \"documents\": [{\"id\": \"321\", \"title\": \"Design Doc\", \"selected\": false}]}, {\"id\":\"234\", \"title\": \"Graphnote\", \"documents\": [{\"id\": \"432\", \"title\": \"Project Kickoff\", \"selected\": false}]},{\"id\":\"345\", \"title\": \"SwiftBook\", \"documents\": [{\"id\": \"543\", \"title\": \"MVP\", \"selected\": false}]},{\"id\":\"456\", \"title\": \"DarkTorch\", \"documents\": [{\"id\": \"543\", \"title\": \"Design Doc\", \"selected\": false}]},]"
//

struct SelectedDocument: Equatable {
    let workspaceId: String
    let documentId: String
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    let moc: NSManagedObjectContext
    
    @EnvironmentObject var dataController: DataController
    @State private var newWorkspaceId = ""
    @State private var newDocumentId = ""
    @State private var selected = SelectedDocument(workspaceId: "", documentId: "")
    @State private var open: Bool = true
    @FetchRequest var workspaces: FetchedResults<Workspace>
    
    @State private var title: String = ""
    @State private var workspaceTitle: String = ""
    
//    @State private var titles: [String: String] = [:]

    init(moc: NSManagedObjectContext) {
        self.moc = moc
        
//        if let dataFromString = jsonString.data(using: .utf8, allowLossyConversion: false) {
//            if let json = try? JSON(data: dataFromString) {
//                data = json.arrayValue.map { row in
//                    let id = row["id"].stringValue
//                    let title = row["title"].stringValue
//                    let documents = row["documents"].arrayValue.map { (id: $0["id"].stringValue, title: $0["title"].stringValue) }
//                    return TreeDatum(id: id, title: title, documents: documents)
//                }
//            }
//        }
//
        
        self._workspaces = FetchRequest(
            entity: Workspace.entity(),
            sortDescriptors: [
                NSSortDescriptor(key: "createdAt", ascending: true)
            ]
        )
        
//        if let baseURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
//            let url = baseURL.appendingPathComponent("Graphnote/Graphnote.sqlite")
//            try! FileManager.default.removeItem(at: url)
//        }
//
        
//        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workspace.fetchRequest()
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        try! self.moc.execute(deleteRequest)
//
//        let workspaceTitles = [
//            "SwiftBook",
//            "DarkTorch",
//            "NSSWitch",
//            "Kanception",
//        ]
//
//        let documentTitles = [
//            "Design Doc",
//            "Project Kickoff",
//            "Technical Specification",
//        ]
//
//
//        for title in workspaceTitles {
//            let workspace = Workspace(context: moc)
//            let createdAt = Date.now
//            workspace.createdAt = createdAt
//            workspace.modifiedAt = createdAt
//            workspace.id = UUID()
//            workspace.title = title
//
//            for docTitle in documentTitles {
//                let document = Document(context: moc)
//                document.id = UUID()
//                document.createdAt = createdAt
//                document.modifiedAt = createdAt
//                document.title = docTitle
//                document.workspace = workspace
//            }
//
//        }
//
//        try! moc.save()
    }
    
    func addWorkspace() {
        let now = Date.now
        let workspace = Workspace(context: moc)
        workspace.id = UUID()
        workspace.title = ""
        workspace.createdAt = now
        workspace.modifiedAt = now
        
        self.newWorkspaceId = workspace.id!.uuidString
        
        try? moc.save()
    }
    
    func addDocument(workspaceId: String) {
        if let workspace = workspaces.filter({ $0.id!.uuidString == workspaceId }).first {
            let now = Date.now
            let document = Document(context: moc)
            document.id = UUID()
            document.title = ""
            document.workspace = workspace
            document.createdAt = now
            document.modifiedAt = now
            
            newDocumentId = document.id!.uuidString
            
            try? moc.save()
        }
    }
    
    func deleteDocument(workspaceId: String, documentId: String) {
        if let workspace = workspaces.filter({ $0.id!.uuidString == workspaceId }).first {
            let items = workspace.mutableSetValue(forKey: "documents")
            
            if let documents = items.allObjects as? [Document], let document = documents.filter({ $0.id!.uuidString == documentId }).first {
                let documentManagedObject = document as NSManagedObject
                moc.delete(documentManagedObject)
                
                try? moc.save()
            }
        }
    }
    
    func deleteWorkspace(id: String) {
        if let workspace = workspaces.filter({ $0.id!.uuidString == id }).first {
            let workspaceManagedObject = workspace as NSManagedObject
            moc.delete(workspaceManagedObject)
            
            try? moc.save()
        }
    }
    
    func setSelectedDocument(documentId: String, workspaceId: String) {
        selected = SelectedDocument(workspaceId: workspaceId, documentId: documentId)
    }
    
    var body: some View {
        let items = workspaces.map { workspace in
            TreeViewItem(
                editable: workspace.id!.uuidString == self.newWorkspaceId,
                newDocumentId: newDocumentId,
                id: workspace.id!.uuidString,
                title: workspace.title!,
                addDocument: addDocument,
                deleteDocument: deleteDocument,
                deleteWorkspace: deleteWorkspace,
                documents: (workspace.documents?.allObjects as? [Document])?.map {
                    Title(id: $0.id!.uuidString, value: $0.title!, selected: workspace.id!.uuidString == selected.workspaceId && $0.id!.uuidString == selected.documentId, createdAt: $0.createdAt!)
                }.sorted {
                    $0.createdAt > $1.createdAt
                } ?? [],
                clearNewIDCallback: {
                    newDocumentId = ""
                    newWorkspaceId = ""
                },
                setSelectedDocument: setSelectedDocument
            )
            
        }
        
        HStack(alignment: .top) {
            if open {
                #if os(macOS)
                ZStack() {
                    EffectView()
                    TreeView(items: items, addWorkspace: addWorkspace) { treeViewItemId, documentId in
                        selected = SelectedDocument(workspaceId: treeViewItemId, documentId: documentId)
                    }
                        .padding()
                       
                }
                .frame(width: treeWidth)
                .edgesIgnoringSafeArea([.bottom])
                #else
                ZStack() {
                    EffectView()
                    TreeView(items: items, addWorkspace: addWorkspace) { treeViewItemId, documentId in
                        selected = SelectedDocument(workspaceId: treeViewItemId, documentId: documentId)
                    }
                        .layoutPriority(treeLayourPriority)
                        
                }
                .frame(width: mobileTreeWidth)
                .edgesIgnoringSafeArea([.top, .bottom])
                #endif
            }
    
            DocumentView(title: $title, workspaceTitle: $workspaceTitle, selected: selected, open: $open)
                .onChange(of: selected, perform: { newValue in
                    if let currentDatum = (workspaces.filter({ $0.id?.uuidString == newValue.workspaceId }).first?.documents?.allObjects as? [Document])?.filter({ doc in doc.id?.uuidString == newValue.documentId }).first {
                    
                        title = currentDatum.title!
                        workspaceTitle = currentDatum.workspace!.title!
                    }
                    
                    
                })
                .onChange(of: title) { newValue in
                    if let workspace = workspaces.filter({ $0.id?.uuidString == selected.workspaceId }).first {
                        if let document = (workspace.documents?.allObjects as? [Document])?.filter({ $0.id?.uuidString == selected.documentId }).first {
                            document.title = newValue
                            // Do this to trick SwiftUI into re-rendering the TreeView
                            workspace.title = workspace.title
                            try? moc.save()
                            
                            
                        }
                        
                    }
                }
            
        }.onAppear {

            if workspaces.count > 0 {
                if let workspace = workspaces.first, let document = (workspace.documents!.allObjects as? [Document])?.first {
                    selected = SelectedDocument(workspaceId: workspace.id!.uuidString, documentId: document.id!.uuidString)
                }
            }
        }
    }
}
