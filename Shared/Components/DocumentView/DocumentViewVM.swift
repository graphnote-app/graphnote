//
//  DocumentViewVM.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

class DocumentViewVM: ObservableObject {
    private func getLastIndex(user: User, workspace: Workspace, document: Document) -> Block? {
        return DataService.shared.getLastBlock(user: user, workspace: workspace, document: document)
    }
    
    @Published var documents: [Document] = []
    
    func fetchDocuments(user: User, workspace: Workspace) {
        do {
            let repo = DocumentRepo(user: user, workspace: workspace)
            let docs = try repo.readAll()
            documents = docs
        } catch let error {
            print(error)
        }
    }
    
    func createLink(user: User, workspace: Workspace, document: Document, content: UUID, prev: UUID?, next: UUID?) {
        let now = Date.now
        // - TODO: BLOCK PREV NEXT
        let link = Block(id: UUID(), type: .contentLink, content: content.uuidString, prev: prev, next: next, graveyard: false, createdAt: now, modifiedAt: now, document: document)
        do {
            _ = try DataService.shared.createBlock(user: user, workspace: workspace, document: document, block: link, prev: prev, next: next)
        } catch let error {
            #if DEBUG
            fatalError()
            #else
            print(error)
            #endif
        }
    }
    
    func updateBlock(_ block: Block, user: User, workspace: Workspace, document: Document, prev: UUID? = nil, next: UUID? = nil, type: BlockType? = nil, text: String? = nil) {
        let next = next ?? block.next
        let prev = prev ?? block.prev
        let type = type ?? block.type
        let text = text ?? block.content
        let updatedBlock = Block(id: block.id, type: type, content: text, prev: prev, next: next, graveyard: block.graveyard, createdAt: block.createdAt, modifiedAt: .now, document: document)
        DataService.shared.updateBlock(user: user, workspace: workspace, document: document, block: updatedBlock)
    }
}
