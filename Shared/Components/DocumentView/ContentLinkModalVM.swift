//
//  ContentLinkModalVM.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/23/23.
//

import Foundation

class ContentLinkModalVM: ObservableObject {
    @Published var blocks: [Block] = []
    @Published var labels: [Label] = []
    @Published var title = ""
    
    private func blockSort(_ a: Block, _ b: Block) -> Bool {
        return true
    }
    
    func fetchDocument(user: User, workspace: Workspace, document: Document) {
        let repo = DocumentRepo(user: user, workspace: workspace)
        do {
            if let blocks = try repo.readBlocks(document: document) {
                self.blocks = blocks.sorted(by: { a, b in
                    blockSort(a, b)
                })
                
            }
            
            if let labels = repo.readLabels(document: document) {
                self.labels = labels
            }
            
            self.title = document.title
            
        } catch let error {
            print(error)
        }
    }
    
    func createLink(user: User, workspace: Workspace, document: Document, content: UUID, prev: UUID?, next: UUID?) {
        let now = Date.now
        // - TODO: BLOCK PREV NEXT
        let link = Block(id: UUID(), type: .contentLink, content: content.uuidString, prev: prev, next: next, createdAt: now, modifiedAt: now, document: document)
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
}
