//
//  DocumentRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData
import SwiftUI

struct DocumentRepo {
    let user: User
    let workspace: Workspace
    
    private let moc = DataController.shared.container.viewContext
    
    func create(block: Block, for user: User) throws -> Bool {
        do {
            guard let documentEntity = try DocumentEntity.getEntity(id: block.document.id, moc: moc) else {
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
    
    func readBlocks(document: Document) throws -> [Block]? {
        do {
            let fetchRequest = BlockEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "document.id == %@", document.id.uuidString)
            let blockEntities = try moc.fetch(fetchRequest)
            return blockEntities.map { blockEntity in
                Block(id: blockEntity.id, type: BlockType(rawValue: blockEntity.type)!, content: blockEntity.content, createdAt: blockEntity.createdAt, modifiedAt: blockEntity.modifiedAt, document: document)
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
    
    func attachExists(label: Label, document: Document) throws -> Bool {
        do {
            let fetchRequest = LabelLinkEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "label == %@ && workspace == %@ && document == %@",
                label.id.uuidString,
                workspace.id.uuidString,
                document.id.uuidString
            )
            
            let labelLinkEntities = try moc.fetch(fetchRequest)
            
            return !labelLinkEntities.isEmpty
            
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readLabels(document: Document) -> [Label]? {
        let labelLinkRepo = LabelLinkRepo(user: user, workspace: workspace)
        
        guard let labelLinks = try? labelLinkRepo.readAll(document: document) else {
            return nil
        }
        
        let labels = labelLinks.compactMap {
            if let labelEntity = try? LabelEntity.getEntity(id: $0.label, moc: moc) {
                return Label(
                    id: labelEntity.id,
                    title: labelEntity.title,
                    color: Color(red: Double(labelEntity.colorRed), green: Double(labelEntity.colorGreen), blue: Double(labelEntity.colorBlue)),
                    workspaceId: labelEntity.workspace.id,
                    createdAt: labelEntity.createdAt,
                    modifiedAt: labelEntity.modifiedAt
                )
            } else {
                return nil
            }
            
        }
        
        return labels
    }
}
