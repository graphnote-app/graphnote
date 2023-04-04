//
//  DataSeeder.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import SwiftUI

struct DataSeeder{
    static func seed(userId: String) -> Bool {
        // Delete the database
        DataController.shared.dropDatabase()
        
        // Info
        let now = Date.now
        
        let user = User(id: userId, createdAt: now, modifiedAt: now)
        
        let workspace = Workspace(id: UUID(), title: "Personal", createdAt: now, modifiedAt: now, user: user, labels: [], documents: [])
        let workspace1 = Workspace(id: UUID(), title: "XYZ", createdAt: now, modifiedAt: now, user: user, labels: [], documents: [])
        let label = Label(id: UUID(), title: "Web 🖥️", color: LabelPalette.allCases().randomElement()!.getColor(), workspaceId: workspace.id, createdAt: now, modifiedAt: now)
        let label2 = Label(id: UUID(), title: "Stuff", color: LabelPalette.allCases().randomElement()!.getColor(), workspaceId: workspace.id, createdAt: now, modifiedAt: now)
        let label3 = Label(id: UUID(), title: "Work in progress", color: LabelPalette.allCases().randomElement()!.getColor(), workspaceId: workspace.id, createdAt: now, modifiedAt: now)
        let label4 = Label(id: UUID(), title: "Project X ❤️", color: LabelPalette.allCases().randomElement()!.getColor(), workspaceId: workspace.id, createdAt: now, modifiedAt: now)
        let label5 = Label(id: UUID(), title: "Graphnote ፨", color: LabelPalette.primary.getColor(), workspaceId: workspace.id, createdAt: now, modifiedAt: now)
        
        let document0 = Document(id: UUID(), title: "Welcome!", createdAt: now, modifiedAt: now)
        let welcomeBlock0 = Block(id: UUID(), type: BlockType.heading3, content: "Thanks for trying Graphnote", createdAt: now, modifiedAt: now, document: document0)
        let welcomeBlock1 = Block(id: UUID(), type: BlockType.heading3, content: "You can create a new document or edit this one!", createdAt: now, modifiedAt: now, document: document0)
        let welcomeBlock2 = Block(id: UUID(), type: BlockType.body, content: "Please reach out with any questions or feedback to graphnote.io@gmail.com", createdAt: now, modifiedAt: now, document: document0)
        
        let document1 = Document(id: UUID(), title: "Tech blog", createdAt: now, modifiedAt: now)
        let block0 = Block(id: UUID(), type: BlockType.body, content: "Hello Graphnote!", createdAt: now, modifiedAt: now, document: document1)
        let block1 = Block(id: UUID(), type: BlockType.body, content: "Thanks for stopping by!", createdAt: now, modifiedAt: now, document: document1)
        let block2 = Block(id: UUID(), type: BlockType.body, content: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", createdAt: now, modifiedAt: now, document: document1)
        
        let document2 = Document(id: UUID(), title: "MVP", createdAt: now, modifiedAt: now)
        let block3 = Block(id: UUID(), type: BlockType.body, content: "The minimal viable product?", createdAt: now, modifiedAt: now, document: document2)
        let block4 = Block(id: UUID(), type: BlockType.body, content: "Hello Graphnote!", createdAt: now, modifiedAt: now, document: document2)
        let block5 = Block(id: UUID(), type: BlockType.body, content: "Hello Graphnote!", createdAt: now, modifiedAt: now, document: document2)
        
//        let blockEmpty = Block(id: UUID(), type: BlockType.empty, content: "", createdAt: now, modifiedAt: now, document: document3)
        
        let workspaces = [workspace, workspace1]
        let labels = [label, label2, label3, label4, label5]
        let documents = [document0, document1, document2]
        let blocks = [welcomeBlock0, welcomeBlock1, welcomeBlock2, block0, block1, block2, block3, block4, block5]
        
        do {

            try UserBuilder.create(user: user)
            let userRepo = UserRepo()
            let workspaceRepo = WorkspaceRepo(user: user)
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            
            for workspace in workspaces {
                if try !userRepo.create(workspace: workspace, for: user) {
                    print("failed to return success from workspace creation: \(workspace)")
                    return false
                }
            }
            
            for document in documents {
                if try !workspaceRepo.create(document: document, in: workspace, for: user) {
                    print("failed to create document :\(document) in workspace: \(workspace)")
                    return false
                }
            }
            
            for label in labels {
                if try !workspaceRepo.create(label: label, in: workspace, for: user) {
                    print("failed to create label :\(label) in workspace: \(workspace)")
                    return false
                }
            }
            
            for i in 0..<blocks.count {
                let block = blocks[i]
                if try !documentRepo.create(block: block, for: user) {
                    print("failed to create block: \(block)")
                    return false
                }
            }
            
//            if try !documentRepo.create(block: blockEmpty, for: user) {
//                print("failed to create block: \(blockEmpty)")
//                return false
//            }
            
            documentRepo.attach(label: label, document: document1)
            documentRepo.attach(label: label5, document: document1)
            documentRepo.attach(label: label2, document: document2)
            documentRepo.attach(label: label4, document: document1)
            documentRepo.attach(label: label5, document: document0)
            documentRepo.attach(label: label2, document: document0)
            documentRepo.attach(label: label3, document: document0)
            documentRepo.attach(label: label4, document: document0)
            
            return true
        
        } catch let error {
            print(error)
            return false
        }

    }
}
