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
    
    func fetchDocument(user: User, workspace: Workspace, document: Document) {
        let repo = DocumentRepo(user: user, workspace: workspace)
        do {
            if let blocks = try repo.readBlocks(document: document) {
                self.blocks = blocks.filter {
                    $0.type != .prompt
                }
            }
            
            if let labels = repo.readLabels(document: document) {
                self.labels = labels
            }
            
            self.title = document.title
            
        } catch let error {
            print(error)
        }
    }
    
    func createLink(user: User, workspace: Workspace, document: Document, content: UUID, order: Int) {
        let now = Date.now
        let link = Block(id: UUID(), type: .contentLink, content: content.uuidString, order: order, createdAt: now, modifiedAt: now, document: document)
        do {
            _ = try DataService.shared.createBlock(user: user, workspace: workspace, document: document, block: link)
        } catch let error {
            #if DEBUG
            fatalError()
            #else
            print(error)
            #endif
        }
    }
}
