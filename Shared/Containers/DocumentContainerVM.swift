//
//  DocumentContainerVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import Foundation

class DocumentContainerVM: ObservableObject {
    private var previousTitle = ""
    private var previousId: UUID? = nil
    private let saveInterval = 2.0
    private var timer: Timer? = nil
    
    init(title: String) {
        self.title = title
        
        self.timer = Timer.scheduledTimer(timeInterval: saveInterval, target: self, selector: #selector(save), userInfo: nil, repeats: true)
//        self.timer = Timer.scheduledTimer(withTimeInterval: saveInterval, repeats: true) { _ in
//            if self.title != self.previousTitle {
//                if let document = self.document?.id, let workspace = self.workspace?.id, let user = self.user {
//                    let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .update, isSynced: false, contents: "{\"id\": \"\(document.uuidString)\", \"workspace\": \"\(workspace.uuidString)\", \"content\": { \"title\": \"\(title)\"}}")
//                    print(SyncService.shared.createMessage(user: user, message: message))
//                }
//                self.previousTitle = self.title
//            }
//        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    func save() {
        if self.title != self.previousTitle && previousId == self.document?.id {
            if let document = self.document?.id, let workspace = self.workspace?.id, let user = self.user {
                let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .update, isSynced: false, contents: "{\"id\": \"\(document.uuidString)\", \"workspace\": \"\(workspace.uuidString)\", \"content\": { \"title\": \"\(title)\"}}")
                print(SyncService.shared.createMessage(user: user, message: message))
            }
        }
        self.previousTitle = self.title
        self.previousId = self.document?.id
    }
    
    @Published var title = ""
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
