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
    
    @Published var content: String = ""
    private var prevContent: String = ""
    
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
        }
    }
}
