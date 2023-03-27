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
    
    func save() throws {
        try? moc.save()
    }
    
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
            
            return true

        } catch let error {
            print(error)
            throw error
        }
    }

    func attach(label: Label, document: Document) -> Bool {
        if let documentEntity = try? DocumentEntity.getEntity(id: document.id, moc: moc), let labelEntity = try? LabelEntity.getEntity(id: label.id, moc: moc) {
            let labelLink = LabelLink(entity: LabelLink.entity(), insertInto: moc)
            labelLink.label = labelEntity
            labelLink.document = documentEntity
            
            return true
        } else {
            print("Failed to attach")
            return false
        }
    }
}
