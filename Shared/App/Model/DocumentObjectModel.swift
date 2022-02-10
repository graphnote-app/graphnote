//
//  DocumentObjectModel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/9/22.
//

import Foundation

final class DocumentObjectModel: ObservableObject {
    @Published var id: UUID
    @Published var title: String
    @Published var createdAt: Date
    @Published var modifiedAt: Date
    @Published var workspaceId: UUID
    
    init(id: UUID, title: String, createdAt: Date, modifiedAt: Date, workspaceId: UUID) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.workspaceId = workspaceId
    }
}
