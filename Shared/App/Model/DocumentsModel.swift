//
//  DocumentsModel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/6/22.
//

import Foundation
import CoreData
import Combine

final class DocumentsModel: ObservableObject {
    let workspaceId: UUID
    @Published var items: [DocumentModel] = []
    let dataController = DataController()

    init(workspaceId: UUID) {
        self.workspaceId = workspaceId
        self.fetchDocuments()
    }
    
    func fetchDocuments() {
        let fetchRequest: NSFetchRequest<Document>
        fetchRequest = Document.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "workspace.id = %@", "\(workspaceId)"
        )
        
        let context = dataController.container.viewContext
        if let documents = try? context.fetch(fetchRequest) {
            self.items = documents.map {
                return DocumentModel(
                    title: $0.title!,
                    coreDataModel: $0
                )
            }
        }
    }
    
}
