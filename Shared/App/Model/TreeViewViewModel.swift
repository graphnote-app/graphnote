//
//  TreeViewViewModel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/9/22.
//

import Foundation
import CoreData

final class TreeViewViewModel: ObservableObject {
    let moc: NSManagedObjectContext

    @Published var workspaces: [Workspace] = []
    @Published var documents: [Document] = []
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
        fetchWorkspaces()
        fetchDocuments()
    }
    
    func fetchWorkspaces() {
        let fetchRequest: NSFetchRequest<Workspace>
        fetchRequest = Workspace.fetchRequest()
        
        if let workspaces = try? moc.fetch(fetchRequest) {
            self.workspaces = workspaces.sorted()
        }
    }
    
    func fetchDocuments() {
        let fetchRequest: NSFetchRequest<Document>
        fetchRequest = Document.fetchRequest()
        
        if let documents = try? moc.fetch(fetchRequest) {
            self.documents = documents
        }
    }
    
    func addWorkspace() {
        let now = Date.now
        let newWorkspace = Workspace(context: moc)
        newWorkspace.id = UUID()
        newWorkspace.createdAt = now
        newWorkspace.modifiedAt = now
        newWorkspace.title = "New Workspace"
        
        try? moc.save()
        
        fetchWorkspaces()
    }
}
