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
    
    private var document: Document?
    
    init(id: UUID, workspaceId: UUID, moc: NSManagedObjectContext) {
        self.id = id
        self.workspaceId = workspaceId
        self.moc = moc
        
        self.fetchDocument(workspaceId: workspaceId, documentId: id)
    }
    
    private func fetchDocument(workspaceId: UUID, documentId: UUID) {
        let fetchRequest: NSFetchRequest<Document>
        fetchRequest = Document.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "workspace.id == %@ && id == %@", workspaceId.uuidString, id.uuidString)
        
        if let document = try? moc.fetch(fetchRequest).first {
            self.title = document.title
            self.workspaceTitle = document.workspace.title
            self.document = document
        }
    }
    
    func setTitle(title: String) {
        document?.title = title
        document?.modifiedAt = Date.now
        self.save()
    }
    
    func setWorkspaceTitle(title: String) {
        document?.workspace.title = title
        document?.workspace.modifiedAt = Date.now
        self.save()
    }
    
    private func save() {
        do {
            try self.moc.save()
        } catch {
            print("Error saving managed object context")
        }
    }
}
