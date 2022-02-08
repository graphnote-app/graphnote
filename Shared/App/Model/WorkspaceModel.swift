//
//  WorkspaceModel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/6/22.
//

import Foundation

class WorkspaceModel: ObservableObject {
    let id: UUID
    @Published var title: String
    let createdAt: Date
    @Published var modifedAt: Date
    let documents: DocumentsModel
    
    init (id: UUID, title: String, documents: DocumentsModel) {
        self.id = id
        self.title = title
        self.documents = documents
        let now = Date.now
        self.createdAt = now
        self.modifedAt = now
    }
}
