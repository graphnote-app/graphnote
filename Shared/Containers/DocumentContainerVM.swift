//
//  DocumentContainerVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import Foundation

class DocumentContainerVM: ObservableObject {
    private var initialized = false
    
    init(title: String) {
        self.title = title
        self.initialized = true
    }
    
    @Published var title = "" {
        didSet {
            if title != oldValue && initialized {
                if let document = document?.id, let workspace = workspace?.id, let user {
                    let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .update, isSynced: false, contents: "{\"id\": \"\(document.uuidString)\", \"workspace\": \"\(workspace.uuidString)\", \"content\": { \"title\": \"\(title)\"}}")
                    print(SyncService.shared.createMessage(user: user, message: message))
                }
            }
        }
    }
    @Published var labels = [Label]()
    @Published var blocks = [Block]()
    
    var document: Document? = nil
    var workspace: Workspace? = nil
    var user: User? = nil
    
    func fetch(user: User, workspace: Workspace, document: Document) {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        if let labels = documentRepo.readLabels(document: document) {
            self.labels = labels
        }
        
        if let blocks = try? documentRepo.readBlocks(document: document) {
            self.blocks = blocks
        }
        
        self.user = user
        self.workspace = workspace
        self.document = document
        self.title = document.title
    }
}
