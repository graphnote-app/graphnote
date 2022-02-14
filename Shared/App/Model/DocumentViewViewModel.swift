//
//  Documents.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/9/22.
//

import Foundation
import CoreData

final class DocumentViewViewModel: ObservableObject {
    let moc: NSManagedObjectContext
    
    let id: UUID
    let workspaceId: UUID
    @Published var title: String = ""
    @Published var workspaceTitle: String = ""
    
//    private var document: Document?
    
    init(id: UUID, workspaceId: UUID, moc: NSManagedObjectContext) {
        self.id = id
        self.workspaceId = workspaceId
        self.moc = moc
        
        if let document = self.fetchDocument(workspaceId: workspaceId, documentId: id) {
            self.title = document.title
            self.workspaceTitle = document.workspace.title
        }
    }
    
    private func fetchDocument(workspaceId: UUID, documentId: UUID) -> Document? {
        let fetchRequest: NSFetchRequest<Document>
        fetchRequest = Document.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "workspace.id == %@ && id == %@", workspaceId.uuidString, documentId.uuidString)
        
        if let document = try? moc.fetch(fetchRequest).first {
            return document
        }
        
        return nil
    }
    
    private func fetchWorkspace(workspaceId: UUID) -> Workspace? {
        let fetchRequest: NSFetchRequest<Workspace>
        fetchRequest = Workspace.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", workspaceId.uuidString)
        
        if let workspace = try? moc.fetch(fetchRequest).first {
            return workspace
        }
        
        return nil
    }
    
    func setTitle(title: String, workspaceId: UUID, documentId: UUID) {
        if let document = fetchDocument(workspaceId: workspaceId, documentId: documentId) {
            document.title = title
            document.modifiedAt = Date.now
            self.save()
        }

    }
    
    func setWorkspaceTitle(title: String, workspaceId: UUID) {
        if let workspace = fetchWorkspace(workspaceId: workspaceId) {
            workspace.title = title
            workspace.modifiedAt = Date.now
            self.save()
        }
        
    }
    
    private func save() {
        do {
            try self.moc.save()
        } catch {
            print("Error saving managed object context")
        }
    }
}
