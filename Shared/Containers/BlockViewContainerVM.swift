//
//  BlockViewContainerVM.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

class BlockViewContainerVM: ObservableObject {
    func insertBlock(index: Int, user: User, workspace: Workspace, document: Document, promptText: String) {
        do {
            let now = Date.now
            
            let type: BlockType = promptText.count == 0 ? .empty : .body
            let block = Block(id: UUID(), type: type, content: promptText, order: index, createdAt: now, modifiedAt: now, document: document)
            
            try DataService.shared.createBlock(user: user, workspace: workspace, document: document, block: block)
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
        }
    }
    
    func movePromptToEmptySpace(index: Int, user: User, workspace: Workspace, document: Document, block: Block) {
        let _block = Block(id: block.id, type: block.type, content: block.content, order: index, createdAt: block.createdAt, modifiedAt: .now, document: document)
        DataService.shared.movePromptToEmptySpace(user: user, workspace: workspace, document: document, block: _block, order: index)
    }
}
