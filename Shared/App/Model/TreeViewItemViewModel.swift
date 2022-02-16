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
    
    
    
}
