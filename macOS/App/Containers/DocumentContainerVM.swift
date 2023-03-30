//
//  DocumentContainerVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import Foundation

class DocumentContainerVM: ObservableObject {
    @Published var title = ""
    @Published var labels = [Label]()
    @Published var blocks = [Block]()
    
    func fetch(user: User, workspace: Workspace, document: Document) {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        print(document)
        
        if let labels = documentRepo.readLabels(document: document) {
            self.labels = labels
        }
        
        if let blocks = try? documentRepo.readBlocks(document: document) {
            self.blocks = blocks
            
        }
        
        self.title = document.title
    }
}
