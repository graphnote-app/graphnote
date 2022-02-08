//
//  DocumentModel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/6/22.
//

import Foundation
import SwiftUI

class DocumentModel: ObservableObject, Identifiable {
    let coreDataModel: Document
    let id: UUID
    @Published var title: String
    let createdAt: Date
    var modifiedAt: Date
    
    init(title: String, coreDataModel: Document) {
        self.title = title
        self.id = UUID()
        let now = Date.now
        self.createdAt = now
        self.modifiedAt = now
        self.coreDataModel = coreDataModel
    }
}
