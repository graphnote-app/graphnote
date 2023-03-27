//
//  WorkspaceRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

struct WorkspaceRepo {
    
    let user: User
    
    private let moc = DataController.shared.container.viewContext
    
    func save() throws {
        try? moc.save()
    }
    
    func create(document: Document, in workspace: Workspace, for user: User) throws -> Bool {
        do {
            guard let workspaceEntity = try WorkspaceEntity.getEntity(id: workspace.id, moc: moc),
                  let userEntity = try UserEntity.getEntity(id: user.id, moc: moc) else {
                return false
            }
            
            let documentEntity = DocumentEntity(entity: DocumentEntity.entity(), insertInto: moc)
            documentEntity.id = document.id
            documentEntity.createdAt = document.createdAt
            documentEntity.modifiedAt = document.modifiedAt
            documentEntity.title = document.title
            documentEntity.workspace = workspaceEntity
            documentEntity.user = userEntity
            
            return true

        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readAll() throws -> [Workspace] {
        do {
            let fetchRequest = WorkspaceEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user.id == %@", user.id.uuidString)
            let workspaces = try moc.fetch(fetchRequest)
            return workspaces.map {
                Workspace(id: $0.id, title: $0.title, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt, user: User(id: $0.user.id, createdAt: $0.user.createdAt, modifiedAt: $0.user.modifiedAt))
            }
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func update(workspace: Workspace) throws {
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
    
    func delete(workspace: Workspace) throws {
        do {
            let fetchRequest = WorkspaceEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", workspace.id.uuidString)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            
            try moc.execute(deleteRequest)
            
        } catch let error {
            print(error)
            throw error
        }
        
    }
    
    private func getUserEntity(id: UUID) throws -> UserEntity? {
        do {
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
            guard let user = try moc.fetch(fetchRequest).first else {
                return nil
            }
            
            return user
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    private func getEntity(id: UUID) throws -> WorkspaceEntity? {
        do {
            let fetchRequest = WorkspaceEntity.fetchRequest()
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
