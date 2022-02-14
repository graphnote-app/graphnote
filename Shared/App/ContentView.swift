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

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var menuOpen = true
    
    @ObservedObject private var viewModel: ContentViewViewModel
    @State private var selectedWorkspace: UUID
    @State private var selectedDocument: UUID
    
    let moc: NSManagedObjectContext

    init(moc: NSManagedObjectContext, initialSelectedDocument: UUID, initalSelectedWorkspace: UUID) {
        self.moc = moc
        self._selectedDocument = State(initialValue: initialSelectedDocument)
        self._selectedWorkspace = State(initialValue: initalSelectedWorkspace)
        self.viewModel = ContentViewViewModel(moc: moc)
        
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if menuOpen {
                #if os(macOS)
                ZStack() {
                    EffectView()
                    TreeView(selectedDocument: $selectedDocument, selectedWorkspace: $selectedWorkspace, moc: moc)
                        .padding()
                }
                .frame(width: treeWidth)
                .edgesIgnoringSafeArea([.bottom])
                #else
                ZStack() {
                    EffectView()
                    TreeView(selectedDocument: $selectedDocument, selectedWorkspace: $selectedWorkspace, moc: moc)
                    .layoutPriority(treeLayourPriority)
                    
                }
                .frame(width: mobileTreeWidth)
                .edgesIgnoringSafeArea([.top, .bottom])
                #endif
            }
            if let selectedDocument = selectedDocument, let selectedWorkspace = selectedWorkspace {
                DocumentView(moc: moc, id: selectedDocument, workspaceId: selectedWorkspace, open: $menuOpen)
            }
            
        }.task {
//            dropDatabase()
//            seed()
//
            if let workspace = viewModel.items.sorted().first, let document = (workspace.documents?.allObjects as? [Document])?.first  {
                selectedWorkspace = workspace.id
                selectedDocument = document.id
            }

        }
        .onChange(of: selectedWorkspace) { newValue in
            viewModel.fetchWorkspaces()
        }
    }
    
    func dropDatabase() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workspace.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! self.moc.execute(deleteRequest)
        
    }
    
    func seed() {
        let workspaceTitles = [
            "SwiftBook",
            "DarkTorch",
            "NSSWitch",
            "Kanception",
        ]

        let documentTitles = [
            "Design Doc",
            "Project Kickoff",
            "Technical Specification",
        ]

        for title in workspaceTitles {
            let workspace = Workspace(context: moc)
            let createdAt = Date.now
            workspace.createdAt = createdAt
            workspace.modifiedAt = createdAt
            workspace.id = UUID()
            workspace.title = title
            
            for docTitle in documentTitles {
                let document = Document(context: moc)
                document.id = UUID()
                let createdAt = Date.now
                document.createdAt = createdAt
                document.modifiedAt = createdAt
                document.title = docTitle
                document.workspace = workspace
            }
            
        }

        try! moc.save()
    }
    
}
