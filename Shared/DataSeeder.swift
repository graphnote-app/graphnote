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
        
        let welcomeBlock0ID = UUID()
        let welcomeBlock1ID = UUID()
        let welcomeBlock2ID = UUID()
        
        let document0 = Document(id: UUID(), title: "Welcome!", focused: nil, createdAt: now, modifiedAt: now, workspace: workspace.id)
        let welcomeBlock0 = Block(id: welcomeBlock0ID, type: BlockType.heading3, content: "Thanks for trying Graphnote", prev: nil, next: welcomeBlock1ID, createdAt: now, modifiedAt: now, document: document0)
        let welcomeBlock1 = Block(id: welcomeBlock1ID, type: BlockType.heading3, content: "You can create a new document or edit this one!", prev: welcomeBlock0ID, next: welcomeBlock2ID, createdAt: now, modifiedAt: now, document: document0)
        let welcomeBlock2 = Block(id: welcomeBlock2ID, type: BlockType.body, content: "Please reach out with any questions or feedback to graphnote.io@gmail.com", prev: welcomeBlock1ID, next: nil, createdAt: now, modifiedAt: now, document: document0)
        
        let block0ID = UUID()
        let block1ID = UUID()
        let block2ID = UUID()
        let block3ID = UUID()
        let block4ID = UUID()
        let block5ID = UUID()
        
        let document1 = Document(id: UUID(), title: "Tech blog", focused: nil, createdAt: now, modifiedAt: now, workspace: workspace.id)
        let block0 = Block(id: block0ID, type: BlockType.body, content: "Hello Graphnote!", prev: nil, next: block1ID, createdAt: now, modifiedAt: now, document: document1)
        let block1 = Block(id: block1ID, type: BlockType.body, content: "Thanks for stopping by!", prev: block0ID, next: block2ID, createdAt: now, modifiedAt: now, document: document1)
        let block2 = Block(id: block2ID, type: BlockType.body, content: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", prev: block1ID, next: nil, createdAt: now, modifiedAt: now, document: document1)
        
        let document2 = Document(id: UUID(), title: "MVP", focused: nil, createdAt: now, modifiedAt: now, workspace: workspace.id)
        let block3 = Block(id: block3ID, type: BlockType.body, content: "The minimal viable product?", prev: nil, next: block4ID, createdAt: now, modifiedAt: now, document: document2)
        let block4 = Block(id: block4ID, type: BlockType.body, content: "Hello Graphnote!", prev: block3ID, next: block5ID, createdAt: now, modifiedAt: now, document: document2)
        let block5 = Block(id: block5ID, type: BlockType.body, content: "Hello Graphnote!", prev: block4ID, next: nil, createdAt: now, modifiedAt: now, document: document2)
        
//        let blockEmpty = Block(id: UUID(), type: BlockType.empty, content: "", createdAt: now, modifiedAt: now, document: document3)
        let prompt0 = Block(id: UUID(), type: .body, content: "", prev: welcomeBlock2.id, next: nil, createdAt: now, modifiedAt: now, document: document0)
        let prompt1 = Block(id: UUID(), type: .body, content: "", prev: block2.id, next: nil, createdAt: now, modifiedAt: now, document: document1)
        let prompt2 = Block(id: UUID(), type: .body, content: "", prev: block5.id, next: nil, createdAt: now, modifiedAt: now, document: document2)
        let workspaces = [workspace]
        let labels = [label, label2, label3, label4, label5]
        let documents = [document0, document1, document2]
        let doc1Blocks = [welcomeBlock0, welcomeBlock1, welcomeBlock2, prompt0]
        let doc2Blocks = [block0, block1, block2, prompt1]
        let doc3Blocks = [block3, block4, block5, prompt2]
        
        do {
            
            try! DataService.shared.createUserMessage(user: user)
            
            for workspace in workspaces {
                try DataService.shared.createWorkspace(user: user, workspace: workspace)
            }
            
            for document in documents {
                try DataService.shared.createDocument(user: user, document: document)
//                let now = Date.now

                
//                try DataService.shared.createBlock(user: user, workspace: workspace, document: document, block: prompt)
            }
            
            for label in labels {
                try! DataService.shared.createLabel(user: user, label: label, workspace: workspace)
            }
            
            for i in 0..<doc1Blocks.count {
                let block = doc1Blocks[i]
                let before = (i - 1) >= 0 && (i - 1) < doc1Blocks.count ? doc1Blocks[i - 1].id : nil
                let after = (i + 1) >= 0 && (i + 1) < doc1Blocks.count ? doc1Blocks[i + 1].id : nil
                try DataService.shared.createBlock(user: user, workspace: workspace, document: document0, block: block, prev: before, next: after)
            }
            
            DataService.shared.updateDocumentFocused(user: user, workspace: workspace, document: document0, focused: doc1Blocks.last?.id)
            
            for i in 0..<doc2Blocks.count {
                let block = doc2Blocks[i]
                let before = (i - 1) >= 0 && (i - 1) < doc2Blocks.count ? doc2Blocks[i - 1].id : nil
                let after = (i + 1) >= 0 && (i + 1) < doc2Blocks.count ? doc2Blocks[i + 1].id : nil
                try DataService.shared.createBlock(user: user, workspace: workspace, document: document1, block: block, prev: before, next: after)
            }
            
            DataService.shared.updateDocumentFocused(user: user, workspace: workspace, document: document1, focused: doc2Blocks.last?.id)
            
            for i in 0..<doc3Blocks.count {
                let block = doc3Blocks[i]
                let before = (i - 1) >= 0 && (i - 1) < doc3Blocks.count ? doc3Blocks[i - 1].id : nil
                let after = (i + 1) >= 0 && (i + 1) < doc3Blocks.count ? doc3Blocks[i + 1].id : nil
                try DataService.shared.createBlock(user: user, workspace: workspace, document: document2, block: block, prev: before, next: after)
            }
            
            DataService.shared.updateDocumentFocused(user: user, workspace: workspace, document: document2, focused: doc3Blocks.last?.id)
            
            try DataService.shared.attachLabel(user: user, label: label, document: document1, workspace: workspace)
            try DataService.shared.attachLabel(user: user, label: label5, document: document1, workspace: workspace)
            try DataService.shared.attachLabel(user: user, label: label2, document: document2, workspace: workspace)
            try DataService.shared.attachLabel(user: user, label: label4, document: document1, workspace: workspace)
            try DataService.shared.attachLabel(user: user, label: label5, document: document0, workspace: workspace)
            try DataService.shared.attachLabel(user: user, label: label2, document: document0, workspace: workspace)
            try DataService.shared.attachLabel(user: user, label: label3, document: document0, workspace: workspace)
            try DataService.shared.attachLabel(user: user, label: label4, document: document0, workspace: workspace)
            
            return true
         
        
        } catch let error {
            print(error)
            return false
        }

    }
}
