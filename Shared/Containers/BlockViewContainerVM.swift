//
//  BlockViewContainerVM.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

class BlockViewContainerVM: ObservableObject {
    func insertBlock(user: User, workspace: Workspace, document: Document, promptText: String, prev: UUID?, next: UUID?) -> Block? {
        do {
            let now = Date.now
            
            let type: BlockType = .body
            let block = Block(id: UUID(), type: type, content: promptText, prev: prev, next: next, createdAt: now, modifiedAt: now, document: document)
            
            return try DataService.shared.createBlock(user: user, workspace: workspace, document: document, block: block, prev: prev, next: next)
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
            return nil
        }
    }
    
    func updateBlock(_ block: Block, user: User, workspace: Workspace, document: Document, prev: UUID? = nil, next: UUID? = nil, type: BlockType? = nil) {
        let next = next ?? block.next
        let prev = prev ?? block.prev
        let type = type ?? block.type
        let updatedBlock = Block(id: block.id, type: type, content: block.content, prev: prev, next: next, createdAt: block.createdAt, modifiedAt: .now, document: document)
        try DataService.shared.updateBlock(user: user, workspace: workspace, document: document, block: updatedBlock)
    }
    
    func movePromptToEmptySpace(user: User, workspace: Workspace, document: Document, block: Block) {
        DataService.shared.movePromptToEmptySpace(user: user, workspace: workspace, document: document, emptyBlock: block)
    }
    
    func backspaceOnEmpty(user: User, workspace: Workspace, document: Document, id: UUID) {
        do {
            let repo = DocumentRepo(user: user, workspace: workspace)
            if let prompt = try repo.readBlock(document: document, block: id) {
                if let allBlocks = try repo.readBlocks(document: document) {
                    let beforeBlock = allBlocks.filter({
                        $0.next == nil
                    }).last
                      
                    if let beforeBlock {
                        if beforeBlock.content == "" {
                            DataService.shared.deleteBlock(user: user, workspace: workspace, id: beforeBlock.id)
                            
                            // - TODO: Update afterBlocks ordering
    //                        let blocksAfter = allBlocks.filter {
    //                            $0.order >= prompt.order
    //                        }
    //
    //                        for after in blocksAfter {
    //                            let block = Block(id: after.id, type: after.type, content: after.content, order: after.order - 1, createdAt: after.createdAt, modifiedAt: .now, document: after.document)
    //                            print(block.order)
    //                            DataService.shared.updateBlock(user: user, workspace: workspace, document: document, block: block)
    //                        }
                        } else {
                            
                            // - TODO: Focus previous text
                        }
                    }
                }                
            }
        } catch let error {
            print(error)
        }
    }
}
