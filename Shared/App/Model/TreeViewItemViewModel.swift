//
//  TreeViewItemViewModel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/13/22.
//

import Foundation
import CoreData

class TreeViewItemViewModel: ObservableObject {
    let moc: NSManagedObjectContext
    
    let workspaceId: UUID
    @Published var title: String = ""
    @Published var documents: [Document] = []
    
    init(moc: NSManagedObjectContext, workspaceId: UUID) {
        self.moc = moc
        self.workspaceId = workspaceId
        fetchDocuments(workspaceId: self.workspaceId)
    }
    
    func fetchDocuments(workspaceId: UUID) {
        let fetchRequest: NSFetchRequest<Document>
        fetchRequest = Document.fetchRequest()
        
        if let documents = try? moc.fetch(fetchRequest) {
            self.documents = documents.filter({$0.workspace.id == workspaceId}).sorted()
        }
    }
    
    func deleteWorkspace(workspaceId: UUID) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workspace.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", workspaceId.uuidString)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.moc.execute(deleteRequest)
        } catch {
            print("Failed to execute delete request.")
        }
    }
    
    func deleteDocument(workspaceId: UUID, documentId: UUID) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Document.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ && workspace.id == %@", documentId.uuidString, workspaceId.uuidString)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try self.moc.execute(deleteRequest)
        } catch {
            print("Failed to execute delete request.")
        }
    }
    
    func addDocument(workspaceId: UUID) -> UUID? {
        
        let fetchRequest: NSFetchRequest<Workspace>
        fetchRequest = Workspace.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", workspaceId.uuidString)
        
        if let workspace = try? moc.fetch(fetchRequest).first {
            let now = Date.now
            let newDocument = Document(context: moc)
            newDocument.id = UUID()
            newDocument.createdAt = now
            newDocument.modifiedAt = now
            newDocument.workspace = workspace
            newDocument.title = "New Doc"
            try? moc.save()
            
            fetchDocuments(workspaceId: workspaceId)
            return newDocument.id
        }
        
        return nil
    }
    
    
}
