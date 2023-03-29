//
//  DataSeeder.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import SwiftUI

struct DataSeeder{
    static func seed() -> Bool {
        // Delete the database
        DataController.shared.dropDatabase()
        
        // Info
        let userId = UUID()
        let now = Date.now
        
        let user = User(id: userId, createdAt: now, modifiedAt: now)
        
        let workspace = Workspace(id: UUID(), title: "Personal", createdAt: now, modifiedAt: now, user: user, labels: [], documents: [])
        let workspace2 = Workspace(id: UUID(), title: "Client X", createdAt: now, modifiedAt: now, user: user, labels: [], documents: [])
        let label = Label(id: UUID(), title: "Web", color: LabelPalette.allCases().randomElement()!.getColor(), workspaceId: workspace.id, createdAt: now, modifiedAt: now)
        let label2 = Label(id: UUID(), title: "Stuff", color: LabelPalette.allCases().randomElement()!.getColor(), workspaceId: workspace.id, createdAt: now, modifiedAt: now)
        let label3 = Label(id: UUID(), title: "Kanception", color: LabelPalette.allCases().randomElement()!.getColor(), workspaceId: workspace.id, createdAt: now, modifiedAt: now)
        
        let document = Document(id: UUID(), title: "Tech blog", createdAt: now, modifiedAt: now)
        let block = Block(id: UUID(), type: BlockType.body, content: "Hello my first string! 1", createdAt: now, modifiedAt: now, document: document)
        let block2 = Block(id: UUID(), type: BlockType.body, content: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", createdAt: now, modifiedAt: now, document: document)
        
        let document2 = Document(id: UUID(), title: "MVP", createdAt: now, modifiedAt: now)
        let block3 = Block(id: UUID(), type: BlockType.body, content: "The minimal viable product?", createdAt: now, modifiedAt: now, document: document2)
        let block4 = Block(id: UUID(), type: BlockType.body, content: "Hello my first string! 4", createdAt: now, modifiedAt: now, document: document2)
        
        let document3 = Document(id: UUID(), title: "Revamp", createdAt: now, modifiedAt: now)
        let block5 = Block(id: UUID(), type: BlockType.body, content: "Hello my first string! 5", createdAt: now, modifiedAt: now, document: document3)
        let block6 = Block(id: UUID(), type: BlockType.body, content: "Hello my first string! 6", createdAt: now, modifiedAt: now, document: document3)
        let blockEmpty = Block(id: UUID(), type: BlockType.empty, content: "", createdAt: now, modifiedAt: now, document: document3)
        
        let workspaces = [workspace, workspace2]
        let labels = [label, label2, label3]
        let documents = [document, document2, document3]
        let blocks = [block, block2, block3, block4, block5, block6]
        
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
                if try !documentRepo.create(block: block, in: documents[Int(i / 2)], for: user) {
                    print("failed to create block: \(block)")
                    return false
                }
            }
            
            if try !documentRepo.create(block: blockEmpty, in: documents[2], for: user) {
                print("failed to create block: \(blockEmpty)")
                return false
            }
            
            documentRepo.attach(label: label, document: document)
            documentRepo.attach(label: label2, document: document2)
            documentRepo.attach(label: label3, document: document3)
            documentRepo.attach(label: label, document: document3)
            
            return true
        
        } catch let error {
            print(error)
            return false
        }

    }
}
