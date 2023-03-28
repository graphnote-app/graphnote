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
        let block = Block(id: UUID(), type: BlockType.body, content: "Hello my first string!", createdAt: now, modifiedAt: now, document: document)
        
        let document2 = Document(id: UUID(), title: "MVP", createdAt: now, modifiedAt: now)
        let block2 = Block(id: UUID(), type: BlockType.body, content: "Hello my first string!", createdAt: now, modifiedAt: now, document: document2)
        
        let document3 = Document(id: UUID(), title: "Revamp", createdAt: now, modifiedAt: now)
        let block3 = Block(id: UUID(), type: BlockType.body, content: "Hello my first string!", createdAt: now, modifiedAt: now, document: document3)
        
        do {

            try UserBuilder.create(user: user)
            let userRepo = UserRepo()
            if try !userRepo.create(workspace: workspace, for: user) {
                print("failed to return success from workspace creation: \(workspace)")
                return false
            }
            
            if try !userRepo.create(workspace: workspace2, for: user) {
                print("failed to return success from workspace creation: \(workspace2)")
                return false
            }

            let workspaceRepo = WorkspaceRepo(user: user)
            if try !workspaceRepo.create(document: document, in: workspace, for: user) {
                print("failed to create document :\(document) in workspace: \(workspace)")
                return false
            }
            
            if try !workspaceRepo.create(document: document2, in: workspace, for: user) {
                print("failed to create document :\(document2) in workspace: \(workspace)")
                return false
            }
            
            if try !workspaceRepo.create(document: document3, in: workspace, for: user) {
                print("failed to create document :\(document3) in workspace: \(workspace)")
                return false
            }
            
            if try !workspaceRepo.create(label: label, in: workspace, for: user) {
                print("failed to create label :\(label) in workspace: \(workspace)")
                return false
            }
            
            if try !workspaceRepo.create(label: label2, in: workspace, for: user) {
                print("failed to create label :\(label2) in workspace: \(workspace)")
                return false
            }
            
            if try !workspaceRepo.create(label: label3, in: workspace, for: user) {
                print("failed to create label :\(label3) in workspace: \(workspace)")
                return false
            }
            
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            if try !documentRepo.create(block: block, in: document, for: user) {
                print("failed to create block: \(block)")
                return false
            }
            
            if try !documentRepo.create(block: block2, in: document2, for: user) {
                print("failed to create block: \(block2)")
                return false
            }
            
            if try !documentRepo.create(block: block3, in: document3, for: user) {
                print("failed to create block: \(block3)")
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
