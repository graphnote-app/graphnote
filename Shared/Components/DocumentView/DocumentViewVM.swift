//
//  DocumentViewVM.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

class DocumentViewVM: ObservableObject {
    private func getLastIndex(user: User, workspace: Workspace, document: Document) -> Int? {
        return DataService.shared.getLastIndex(user: user, workspace: workspace, document: document)
    }

    func appendBlock(user: User, workspace: Workspace, document: Document, text: String = "New block") {
        do {
            let now = Date.now
            if let index = getLastIndex(user: user, workspace: workspace, document: document) {
                let block = Block(id: UUID(), type: .body, content: text, order: index + 1, createdAt: now, modifiedAt: now, document: document)
                try DataService.shared.createBlock(user: user, workspace: workspace, document: document, block: block)
            } else {
                let block = Block(id: UUID(), type: .body, content: text, order: 0, createdAt: now, modifiedAt: now, document: document)
                try DataService.shared.createBlock(user: user, workspace: workspace, document: document, block: block)
            }
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
        }
    }
}
