//
//  DocumentRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

struct DocumentRepo {
    
    let workspace: Workspace
    
    private let moc = DataController.shared.container.viewContext
    
    func create(block: Block, in document: Document, for user: User) throws -> Bool {
        do {
            guard let documentEntity = try DocumentEntity.getEntity(id: document.id, moc: moc) else {
                return false
            }
            
            let blockEntity = BlockEntity(entity: BlockEntity.entity(), insertInto: moc)
            blockEntity.id = block.id
            blockEntity.type = block.type.rawValue
            blockEntity.content = block.content
            blockEntity.createdAt = block.createdAt
            blockEntity.modifiedAt = block.modifiedAt
            blockEntity.document = documentEntity
            
            try? moc.save()
            
            return true

        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readAll() throws -> [Document] {
        do {
            let fetchRequest = DocumentEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "workspace.id == %@", workspace.id.uuidString)
            let documentEntities = try moc.fetch(fetchRequest)
            return documentEntities.map { documentEntity in
                Document(id: documentEntity.id, title: documentEntity.title, createdAt: documentEntity.createdAt, modifiedAt: documentEntity.modifiedAt)
            }
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func update(document: Document, title: String? = nil) {
        if let documentEntity = try? DocumentEntity.getEntity(id: document.id, moc: moc), let title {
            documentEntity.title = title
            try? moc.save()
        }
    }

    func attach(label: Label, document: Document) {
        let labelLink = LabelLinkEntity(entity: LabelLinkEntity.entity(), insertInto: moc)
        labelLink.label = label.id
        labelLink.document = document.id
        labelLink.workspace = workspace.id
        labelLink.id = UUID()
        labelLink.createdAt = .now
        labelLink.modifiedAt = .now
        
        try? moc.save()
    }
}
