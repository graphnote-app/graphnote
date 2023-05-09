//
//  BlockViewVM.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import Foundation

class BlockViewVM: ObservableObject {
    private let saveInterval = 2.0
    private var timer: Timer? = nil
    
    @Published var content: String = "INIT" {
        didSet {
            prevContent = oldValue
        }
    }
    
    var prevContent: String = "INIT"
    
    let user: User
    let workspace: Workspace
    let document: Document
    let block: Block
    
    init(text: String, user: User, workspace: Workspace, document: Document, block: Block) {
        self.content = text
        self.user = user
        self.workspace = workspace
        self.document = document
        self.block = block
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(timeInterval: saveInterval, target: self, selector: #selector(save), userInfo: nil, repeats: true)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    func save() {
        if content != prevContent && content != block.content {
            DataService.shared.updateBlock(user: user, workspace: workspace, document: document, block: block, content: content)
            prevContent = content
            fetch()
        }
    }
    
    func deleteBlock(block: Block, user: User, workspace: Workspace) throws {
        do {
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            
            var delete = false
            
            if let prevUUID = block.prev {
                if let prev = readBlock(id: prevUUID, user: user, workspace: workspace) {
                    let updatedPrev = Block(id: prev.id,
                                          type: prev.type,
                                       content: prev.content,
                                          prev: prev.prev,
                                          next: block.next,
                                     createdAt: prev.createdAt,
                                    modifiedAt: .now,
                                      document: document)
                    documentRepo.update(block: updatedPrev)
                    delete = true
                }
            }
            
            if let nextUUID = block.next {
                if let next = readBlock(id: nextUUID, user: user, workspace: workspace) {
                    let updatedNext = Block(id: next.id,
                                          type: next.type,
                                       content: next.content,
                                          prev: block.prev,
                                          next: next.next,
                                     createdAt: next.createdAt,
                                    modifiedAt: .now,
                                      document: document)
                    documentRepo.update(block: updatedNext)
                    delete = true
                }
            }
            
            if delete {
                try documentRepo.deleteBlock(id: block.id)
            }
            
        } catch let error {
            print(error)
        }
    }
    
    func readBlock(id: UUID, user: User, workspace: Workspace) -> Block? {
        do {
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            return try documentRepo.readBlock(document: document, block: id)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func fetch() {
        if let block = DataService.shared.readBlock(user: user, workspace: workspace, document: document, block: block.id) {
            if block.content != content {
                content = block.content
            }
        }

    }
    
    func getBlockText(id: UUID) -> String? {
        let block = DataService.shared.readBlock(user: user, workspace: workspace, document: document, block: id)
        return block?.content
    }
}
