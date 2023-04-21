//
//  DataSeeder.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import SwiftUI

struct DataSeeder{
    static func seed(user: User) -> Bool {
        // Delete the database
        DataController.shared.dropDatabase()
        
        // Info
        let now = Date.now
        
        let workspace = Workspace(id: UUID(), title: "Personal", createdAt: now, modifiedAt: now, user: user.id, labels: [], documents: [])
        let workspace1 = Workspace(id: UUID(), title: "XYZ", createdAt: now, modifiedAt: now, user: user.id, labels: [], documents: [])
        let label = Label(id: UUID(), title: "Web 🖥️", color: LabelPalette.allCases().randomElement()!, workspace: workspace.id, user: user.id, createdAt: now, modifiedAt: now)
        let label2 = Label(id: UUID(), title: "Stuff", color: LabelPalette.allCases().randomElement()!, workspace: workspace.id, user: user.id, createdAt: now, modifiedAt: now)
        let label3 = Label(id: UUID(), title: "Work in progress", color: LabelPalette.allCases().randomElement()!, workspace: workspace.id, user: user.id, createdAt: now, modifiedAt: now)
        let label4 = Label(id: UUID(), title: "Project X ❤️", color: LabelPalette.allCases().randomElement()!, workspace: workspace.id, user: user.id, createdAt: now, modifiedAt: now)
        let label5 = Label(id: UUID(), title: "Graphnote ፨", color: LabelPalette.primary, workspace: workspace.id, user: user.id, createdAt: now, modifiedAt: now)
        
        let document0 = Document(id: UUID(), title: "Welcome!", createdAt: now, modifiedAt: now, workspace: workspace.id)
        let welcomeBlock0 = Block(id: UUID(), type: BlockType.heading3, content: "Thanks for trying Graphnote", order: 0, createdAt: now, modifiedAt: now, document: document0)
        let welcomeBlock1 = Block(id: UUID(), type: BlockType.heading3, content: "You can create a new document or edit this one!", order: 1, createdAt: now, modifiedAt: now, document: document0)
        let welcomeBlock2 = Block(id: UUID(), type: BlockType.body, content: "Please reach out with any questions or feedback to graphnote.io@gmail.com", order: 2, createdAt: now, modifiedAt: now, document: document0)
        
        let document1 = Document(id: UUID(), title: "Tech blog", createdAt: now, modifiedAt: now, workspace: workspace.id)
        let block0 = Block(id: UUID(), type: BlockType.body, content: "Hello Graphnote!", order: 0, createdAt: now, modifiedAt: now, document: document1)
        let block1 = Block(id: UUID(), type: BlockType.body, content: "Thanks for stopping by!", order: 1, createdAt: now, modifiedAt: now, document: document1)
        let block2 = Block(id: UUID(), type: BlockType.body, content: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.BREAKLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", order: 2, createdAt: now, modifiedAt: now, document: document1)
        
        let document2 = Document(id: UUID(), title: "MVP", createdAt: now, modifiedAt: now, workspace: workspace.id)
        let block3 = Block(id: UUID(), type: BlockType.body, content: "The minimal viable product?", order: 0, createdAt: now, modifiedAt: now, document: document2)
        let block4 = Block(id: UUID(), type: BlockType.body, content: "Hello Graphnote!", order: 1, createdAt: now, modifiedAt: now, document: document2)
        let block5 = Block(id: UUID(), type: BlockType.body, content: "Hello Graphnote!", order: 2, createdAt: now, modifiedAt: now, document: document2)

        
//        let blockEmpty = Block(id: UUID(), type: BlockType.empty, content: "", createdAt: now, modifiedAt: now, document: document3)
        
        let workspaces = [workspace, workspace1]
        let labels = [label, label2, label3, label4, label5]
        let documents = [document0, document1, document2]
        let doc1Blocks = [welcomeBlock0, welcomeBlock1, welcomeBlock2]
        let doc2Blocks = [block0, block1, block2]
        let doc3Blocks = [block3, block4, block5]
        
        do {
            
            try! DataService.shared.createUserMessage(user: user)
            
            for workspace in workspaces {
                try! DataService.shared.createWorkspace(user: user, workspace: workspace)
            }
            
            for document in documents {
                try! DataService.shared.createDocument(user: user, document: document)
            }
            
            for label in labels {
                try! DataService.shared.createLabel(user: user, label: label, workspace: workspace)
            }
            
            for i in 0..<doc1Blocks.count {
                let block = doc1Blocks[i]
                try! DataService.shared.createBlock(user: user, workspace: workspace, document: document0, block: block)
            }
            
            for i in 0..<doc2Blocks.count {
                let block = doc2Blocks[i]
                try! DataService.shared.createBlock(user: user, workspace: workspace, document: document1, block: block)
            }
            
            for i in 0..<doc3Blocks.count {
                let block = doc3Blocks[i]
                try! DataService.shared.createBlock(user: user, workspace: workspace, document: document2, block: block)
            }
            
            try! DataService.shared.attachLabel(user: user, label: label, document: document1, workspace: workspace)
            try! DataService.shared.attachLabel(user: user, label: label5, document: document1, workspace: workspace)
            try! DataService.shared.attachLabel(user: user, label: label2, document: document2, workspace: workspace)
            try! DataService.shared.attachLabel(user: user, label: label4, document: document1, workspace: workspace)
            try! DataService.shared.attachLabel(user: user, label: label5, document: document0, workspace: workspace)
            try! DataService.shared.attachLabel(user: user, label: label2, document: document0, workspace: workspace)
            try! DataService.shared.attachLabel(user: user, label: label3, document: document0, workspace: workspace)
            try! DataService.shared.attachLabel(user: user, label: label4, document: document0, workspace: workspace)
            
            return true
         
        
        } catch let error {
            print(error)
            return false
        }

    }
}
