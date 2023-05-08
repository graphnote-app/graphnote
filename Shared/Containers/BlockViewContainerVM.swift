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
    
    func updateBlock(_ block: Block, user: User, workspace: Workspace, document: Document, prev: UUID? = nil, next: UUID? = nil, type: BlockType? = nil, text: String? = nil) {
        let next = next ?? block.next
        let prev = prev ?? block.prev
        let type = type ?? block.type
        let text = text ?? block.content
        let updatedBlock = Block(id: block.id, type: type, content: text, prev: prev, next: next, createdAt: block.createdAt, modifiedAt: .now, document: document)
        DataService.shared.updateBlock(user: user, workspace: workspace, document: document, block: updatedBlock)
    }

}
