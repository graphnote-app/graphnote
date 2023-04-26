//
//  BlockViewContainerVM.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

class BlockViewContainerVM: ObservableObject {
    func insertBlock(index: Int, user: User, workspace: Workspace, document: Document, promptText: String) -> Block? {
        do {
            let now = Date.now
            
            let type: BlockType = promptText.count == 0 ? .empty : .body
            let block = Block(id: UUID(), type: type, content: promptText, order: index, createdAt: now, modifiedAt: now, document: document)
            
            return try DataService.shared.createBlock(user: user, workspace: workspace, document: document, block: block)
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
            return nil
        }
    }
    
    func movePromptToEmptySpace(index: Int, user: User, workspace: Workspace, document: Document, block: Block) {
        DataService.shared.movePromptToEmptySpace(user: user, workspace: workspace, document: document, emptyBlock: block, order: index)
    }
    
    func backspaceOnEmpty(user: User, workspace: Workspace, document: Document, id: UUID) {
        do {
            let repo = DocumentRepo(user: user, workspace: workspace)
            if let prompt = try repo.readBlock(document: document, block: id) {
                let allBlocks = try repo.readAllBlocks(document: document).sorted(by: { a, b in
                    a.order < b.order
                })
                
                let beforeBlock = allBlocks.filter({
                    $0.order <= prompt.order - 1
                }).last
                  
                if let beforeBlock {
                    if beforeBlock.content == "" {
                        DataService.shared.deleteBlock(user: user, workspace: workspace, id: beforeBlock.id)
                        
                        // - TODO: Update afterBlocks ordering
                    } else {
                        
                        // - TODO: Focus previous text
                    }
                }
            }
        } catch let error {
            print(error)
        }
    }
}
