//
//  Documents.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/9/22.
//

import Foundation
import CoreData

final class Documents: ObservableObject {
    private let dataController = DataController()

    @Published var items: [DocumentObjectModel] = []
    
    init() {}
    
    func fetchDocuments(workspaceId: UUID) {
        let fetchRequest: NSFetchRequest<Document>
        fetchRequest = Document.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "workspace.id == %@", workspaceId.uuidString)
        
        let context = dataController.container.viewContext
        if let documents = try? context.fetch(fetchRequest) {
            self.items = documents.map {
                DocumentObjectModel(id: $0.id!, title: $0.title!, createdAt: $0.createdAt!, modifiedAt: $0.modifiedAt!, workspaceId: workspaceId)
            }
        }
    }
}
