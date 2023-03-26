//
//  WorkspaceRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

struct WorkspaceRepo {
    
    static func createWorkspace() throws {
        let moc = DataController.shared.container.viewContext
        let workspace = WorkspaceEntity(entity:  WorkspaceEntity.entity(), insertInto: moc)
        let now = Date.now
        workspace.createdAt = now
        workspace.modifiedAt = now
        workspace.id = UUID()
        workspace.title = "New workspace"
    }
    
    static func fetchWorkspaces() throws -> [Workspace] {
        let moc = DataController.shared.container.viewContext
        let fetchRequest = WorkspaceEntity.fetchRequest()
        
        do {
            let workspaces = try moc.fetch(fetchRequest)
            return workspaces.map {
                Workspace(id: $0.id, title: $0.title, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt)
            }
            
        } catch let error {
            throw error
        }
    }
}
