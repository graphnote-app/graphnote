//
//  WorkspaceRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

struct WorkspaceRepo {
    
    static private let moc = DataController.shared.container.viewContext
    static private let fetchRequest = WorkspaceEntity.fetchRequest()
    
    static func create(workspace: Workspace) throws {
        let workspaceEntity = WorkspaceEntity(entity: WorkspaceEntity.entity(), insertInto: moc)
        
        workspaceEntity.id = workspace.id
        workspaceEntity.createdAt = workspace.createdAt
        workspaceEntity.modifiedAt = workspace.modifiedAt
        workspaceEntity.title = workspace.title
        
        do {
            try moc.save()
        } catch let error {
            print(error)
            throw error
        }
    }
    
    static func read() throws -> [Workspace] {
        do {
            let workspaces = try moc.fetch(fetchRequest)
            return workspaces.map {
                Workspace(id: $0.id, title: $0.title, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt)
            }
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    static func update(workspace: Workspace) throws {
        do {
            guard let workspaceEntity = try getEntity(id: workspace.id) else {
                return
            }
            
            workspaceEntity.title = workspace.title
            workspaceEntity.createdAt = workspace.createdAt
            workspaceEntity.modifiedAt = workspace.modifiedAt
        } catch let error {
            print(error)
            throw error
        }
    }
    
    static func delete(workspace: Workspace) throws {
        do {
            fetchRequest.predicate = NSPredicate(format: "id == %@", workspace.id.uuidString)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            
            try moc.execute(deleteRequest)
            try moc.save()
            
        } catch let error {
            print(error)
            throw error
        }
        
    }
    
    static private func getEntity(id: UUID) throws -> WorkspaceEntity? {
        do {
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
            guard let workspace = try moc.fetch(fetchRequest).first else {
                return nil
            }
            
            return workspace
            
        } catch let error {
            print(error)
            throw error
        }
    }
}
