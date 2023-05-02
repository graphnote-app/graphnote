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
    @Published var allLabels = [Label]()
    
    var document: Document? = nil {
        didSet {
            if document?.title != oldValue?.title || document?.id != oldValue?.id {
                self.previousId = oldValue?.id
                if let document {
                    self.title = document.title
                    self.previousTitle = self.title
                }
            }
        }
    }

    var workspace: Workspace? = nil
    var user: User? = nil
    
    func fetchBlocks(user: User, workspace: Workspace, document: Document) {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        do {
            if let blocks = try documentRepo.readBlocks(document: document) {
                self.blocks = blocks
            }
        } catch let error {
            print(error)
            return
        }
    }
    
    func fetch(user: User, workspace: Workspace, document: Document) {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        if let labels = documentRepo.readLabels(document: document) {
            if labels != self.labels {
                self.labels = labels
            }
        }
        
        do {
            
            let allLabels = try WorkspaceRepo(user: user).readAllLabels(workspace: workspace)
            if allLabels != self.allLabels {
                self.allLabels = allLabels
            }
            
            if let blocks = try documentRepo.readBlocks(document: document) {
                if blocks != self.blocks {
                    self.blocks = blocks
                }
            }
        } catch let error {
            print(error)
            return
        }
        
        self.user = user
        self.workspace = workspace
        
        do {
            if let doc = try documentRepo.read(id: document.id) {
                self.document = doc
            }
        } catch let error {
            print(error)
            return
        }
        
        if document.title != self.title {
            self.title = document.title
        }
        
        if self.previousId == nil  {
            self.previousId = document.id
        }
        
        if self.previousTitle == nil {
            self.previousTitle = document.title
        }
    }
}
