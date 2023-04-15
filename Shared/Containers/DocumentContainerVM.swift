//
//  DocumentContainerVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import Foundation

class DocumentContainerVM: ObservableObject {
    private var previousTitle: String? = nil
    private var previousId: UUID? = nil
    private let saveInterval = 2.0
    private var timer: Timer? = nil
    
    init() {
        self.timer = Timer.scheduledTimer(timeInterval: saveInterval, target: self, selector: #selector(save), userInfo: nil, repeats: true)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    func save() {
        if self.title != self.previousTitle && previousId == self.document?.id {
//            print("title: \(self.title) previousTitle: \(previousTitle) id: \(document?.id) previousId: \(previousId)")
            if let document = self.document, let workspace = self.workspace, let user = self.user {
                DataService.shared.updateDocumentTitle(user: user, workspace: workspace, document: document, title: self.title)
            }
            self.previousTitle = title
            self.previousId = document?.id
        }
    }
    
    @Published var title = ""
    @Published var labels = [Label]()
    @Published var blocks = [Block]()
    
    var document: Document? = nil {
        didSet {
            self.previousId = oldValue?.id
            if let document {
                self.title = document.title
                self.previousTitle = self.title
            }
        }
    }
    
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
        
        if self.previousId == nil  {
            self.previousId = document.id
        }
        
        if self.previousTitle == nil {
            self.previousTitle = document.title
        }
    }
}
