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
    
    private var block: Block? = nil
    
    var prevContent: String = "INIT"
    
    let user: User
    let workspace: Workspace
    let document: Document
    let blockId: UUID
    
        
    init(text: String, user: User, workspace: Workspace, document: Document, block: UUID) {
        self.content = text
        self.user = user
        self.workspace = workspace
        self.document = document
        self.blockId = block
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
        guard let block else {
            return
        }
        
        if content != prevContent && content != block.content {
            
//            if let localBlock = DataService.shared.readBlock(user: user, workspace: workspace, document: document, block: block.id) {
            let contentCapture = content
            fetch(force: true)
//            print("BLOCK: \(localBlock)")
            DataService.shared.updateBlock(user: user, workspace: workspace, document: document, block: block, content: contentCapture)
            prevContent = contentCapture
            fetch()
//            }
            
        }
    }
    
    func deleteBlock(block: Block, user: User, workspace: Workspace) throws {
        DataService.shared.deleteBlock(user: user, workspace: workspace, block: block)
        do {
//            let documentRepo = DocumentRepo(user: user, workspace: workspace)
//
//            let updateBlock = Block(id: block.id,
//                                  type: block.type,
//                               content: block.content,
//                                  prev: block.prev,
//                                  next: block.next,
//                             graveyard: true,
//                             createdAt: block.createdAt,
//                            modifiedAt: .now,
//                              document: document)
//            documentRepo.update(block: updateBlock)

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
    
    func fetch(force: Bool = false) {
        if let block = DataService.shared.readBlock(user: user, workspace: workspace, document: document, block: blockId) {
            if (block.content != content) || force {
                content = block.content
            }
            
            self.block = block
        }

    }
    
    func getBlockText(id: UUID) -> String? {
        let block = DataService.shared.readBlock(user: user, workspace: workspace, document: document, block: id)
        return block?.content
    }
}
