//
//  DocumentRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData
import SwiftUI

enum DocumentRepoError: Error {
    case nilWorkspace
}

struct DocumentRepo {
    let user: User
    let workspace: Workspace
    
    private let moc = DataController.shared.container.viewContext
    
    func create(block: Block) throws -> Bool {
        do {
            guard let documentEntity = try DocumentEntity.getEntity(id: block.document.id, moc: moc) else {
                return false
            }
            
            let blockEntity = BlockEntity(entity: BlockEntity.entity(), insertInto: moc)
            blockEntity.id = block.id
            blockEntity.type = block.type.rawValue
            blockEntity.content = block.content
            blockEntity.createdAt = block.createdAt
            blockEntity.prev = block.prev
            blockEntity.next = block.next
            blockEntity.graveyard = block.graveyard
            blockEntity.modifiedAt = block.modifiedAt
            blockEntity.document = documentEntity
            
            try moc.save()
            
            return true
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readAllBlocks(document: Document) throws -> [Block] {
        do {
            
            let fetchRequest = BlockEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "document.id == %@", document.id.uuidString)
            let blockEntities = try moc.fetch(fetchRequest)
            return try blockEntities.map { blockEntity in
                try Block(from: blockEntity)
            }
            
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
            return try documentEntities.map { documentEntity in
                guard let workspace = documentEntity.workspace else {
                    throw DocumentRepoError.nilWorkspace
                }
                
                return Document(id: documentEntity.id, title: documentEntity.title, focused: documentEntity.focused, createdAt: documentEntity.createdAt, modifiedAt: documentEntity.modifiedAt, workspace: workspace.id)
            }
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readPromptBlock(document: Document) throws -> Block? {
        do {
            let fetchRequest = BlockEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "type == %@ && document.id == %@", "prompt", document.id.uuidString)
            if let blockEntity = try moc.fetch(fetchRequest).first {
                return try Block(from: blockEntity)
            } else {
                return nil
            }
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func read(id: UUID) throws -> Document? {
        do {
            let fetchRequest = DocumentEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
            let documentEntities = try moc.fetch(fetchRequest)
            return try documentEntities.first.map { entity in
                guard let workspace = entity.workspace else {
                    throw DocumentRepoError.nilWorkspace
                }
                
                return Document(id: entity.id, title: entity.title, focused: entity.focused, createdAt: entity.createdAt, modifiedAt: entity.modifiedAt, workspace: workspace.id)
            }
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    
    func readBlocks(document: Document) throws -> [Block]? {
        do {
            let fetchRequest = BlockEntity.fetchRequest()
//            let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
            fetchRequest.predicate = NSPredicate(format: "document.id == %@", document.id.uuidString)
//            fetchRequest.sortDescriptors = [sortDescriptor]
            let blockEntities = try moc.fetch(fetchRequest)
            
            let blocks = blockEntities.map { blockEntity in
                Block(id: blockEntity.id, type: BlockType(rawValue: blockEntity.type)!, content: blockEntity.content, prev: blockEntity.prev, next: blockEntity.next, graveyard: blockEntity.graveyard, createdAt: blockEntity.createdAt, modifiedAt: blockEntity.modifiedAt, document: document)
            }
            
            var curr: Block? = blocks.first(where: {$0.prev == nil})
            var blocksOut: [Block] = []
            while curr != nil {
                if let curr {
                    blocksOut.append(curr)
                }

                curr = blocks.first(where: {$0.id == curr?.next})
            }
            
            // MARK: - DEBUG VISUAL
            
            if DEBUG_VISUAL_LINKED_LIST {
                let blocksOutSet = Set(blocksOut)
                
                let blocksSet = Set(blocks)

                let diffSet = blocksSet.subtracting(blocksOutSet)
                
                blocksOut.append(Block(id: UUID(), type: .body, content: "SENTINEL BLOCK", prev: blocksOut.last?.id, next: diffSet.first?.id, graveyard: false, createdAt: .now, modifiedAt: .now, document: document))
                blocksOut.append(contentsOf: diffSet)
            }
            
            return blocksOut

        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readBlock(document: Document, block: UUID) throws -> Block? {
        do {
            let fetchRequest = BlockEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", block.uuidString)
            let blockEntities = try moc.fetch(fetchRequest)
            return blockEntities.compactMap { blockEntity in
                try? Block(from: blockEntity)
            }.first
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readAllWhere(document: Document, orderEqualsOrGreaterThan: Int) throws -> [Block]? {
        do {
//            let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
            let fetchRequest = BlockEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "document.id == %@ && order >= %@", document.id.uuidString, NSNumber(value: orderEqualsOrGreaterThan))
//            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let blockEntities = try moc.fetch(fetchRequest)
            return try blockEntities.compactMap {
                try Block(from: $0)
            }
//            }.sorted(by: { blockA, blockB in
//                blockA.order < blockB.order
//            })
            
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func update(document: Document) -> Bool {
        do {
            if let documentEntity = try DocumentEntity.getEntity(id: document.id, moc: moc) {
                documentEntity.title = document.title
                documentEntity.focused = document.focused
                documentEntity.modifiedAt = document.modifiedAt
                try moc.save()
            }
            
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    func update(block: Block) -> Bool {
        do {
            if let blockEntity = try BlockEntity.getEntity(id: block.id, moc: moc) {
                blockEntity.content = block.content
                blockEntity.modifiedAt = block.modifiedAt
                blockEntity.prev = block.prev
                blockEntity.next = block.next
                blockEntity.type = block.type.rawValue
                blockEntity.graveyard = block.graveyard
                try moc.save()
            }
            
            return true
        } catch let error {
            print(error)
            return false
        }
    }

    func attach(label: Label, document: Document) -> LabelLink? {
        do {
            let labelLink = LabelLinkEntity(entity: LabelLinkEntity.entity(), insertInto: moc)
            labelLink.label = label.id
            labelLink.document = document.id
            labelLink.workspace = workspace.id
            labelLink.id = UUID()
            labelLink.createdAt = .now
            labelLink.modifiedAt = .now
            print(workspace.id)
            print(label.workspace)
            try moc.save()
            
            return LabelLink(id: labelLink.id,
                             label: labelLink.label,
                             document: labelLink.document,
                             workspace: labelLink.workspace,
                             createdAt: labelLink.createdAt,
                             modifiedAt: labelLink.modifiedAt
            )
            
        } catch let error {
            print(error)
            return nil
        }
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
        let labelLinkRepo = LabelLinkRepo(user: user)
        
        guard let labelLinks = try? labelLinkRepo.readAll(document: document) else {
            return nil
        }
        
        do {
            let labels = try labelLinks.compactMap {
                if let labelEntity = try? LabelEntity.getEntity(id: $0.label, moc: moc),
                   let workspace = labelEntity.workspace, let user = labelEntity.user {
                    return try Label(from: labelEntity)
                } else {
                    return nil
                }
                
            }
            
            return labels
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func getLastBlock(document: Document) -> Block? {
        do {
            let sortDescriptor = NSSortDescriptor(key: "order", ascending: false)
            let fetchRequest = BlockEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "document.id == %@", document.id.uuidString)
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            if let blockEntity = try moc.fetch(fetchRequest).first {
                return try Block(from: blockEntity)
            }
            
        } catch let error {
            print(error)
        }
        
        return nil
    }
    
    func deleteBlock(id: UUID) throws {
        do {
            if let blockEntity = try BlockEntity.getEntity(id: id, moc: moc) {
                blockEntity.graveyard = true
                blockEntity.modifiedAt = .now
                try moc.save()
            }
        } catch let error {
            print(error)
        }
    }
}
