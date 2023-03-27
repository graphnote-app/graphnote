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
        let workspace = Workspace(id: UUID(), title: "Personal", createdAt: now, modifiedAt: now, user: user)
        let workspace2 = Workspace(id: UUID(), title: "Work", createdAt: now, modifiedAt: now, user: user)
        let label = Label(id: UUID(), title: "Web", color: Color(red: 12.0, green: 12.0, blue: 12.0), createdAt: now, modifiedAt: now)
        let document = Document(id: UUID(), title: "Tech blog", createdAt: now, modifiedAt: now, workspace: workspace, labels: [label])
        let block = Block(id: UUID(), type: BlockType.body, content: "Hello my first string!", createdAt: now, modifiedAt: now, document: document)
        
        do {

            try UserBuilder.create(user: user)
            let userRepo = UserRepo()
            if try !userRepo.create(workspace: workspace, for: user) {
                print("failed to return success from workspace creation: \(workspace)")
                return false
            }
            
            if try !userRepo.create(workspace: workspace2, for: user) {
                print("failed to return success from workspace2 creation: \(workspace2)")
                return false
            }
            
            let workspaceRepo = WorkspaceRepo(user: user)
            if try !workspaceRepo.create(document: document, in: workspace, for: user) {
                print("failed to create document :\(document) in workspace: \(workspace)")
                return false
            }
            
            let documentRepo = DocumentRepo(workspace: workspace)
            if try !documentRepo.create(block: block, in: document, for: user) {
                print("failed to create block: \(block)")
                return false
            }
            
            let labelRepo = LabelRepo(user: user, workspace: workspace)
            if !labelRepo.create(label: label) {
                print("Failed to create the label: \(label)")
                return false
            }
            
            documentRepo.attach(label: label, document: document)
            
            return true
        
        } catch let error {
            print(error)
            return false
        }

    }
}
