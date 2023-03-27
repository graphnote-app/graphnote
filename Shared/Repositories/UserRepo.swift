//
//  UserRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

struct UserRepo {
    
    private let moc = DataController.shared.container.viewContext
    
    func save() throws {
        try? moc.save()
    }
    
    func create(workspace: Workspace, for user: User) throws -> Bool {
        do {
            guard let userEntity = try getUserEntity(id: user.id) else {
                return false
            }
            
            let workspaceEntity = WorkspaceEntity(entity: WorkspaceEntity.entity(), insertInto: moc)
            workspaceEntity.id = workspace.id
            workspaceEntity.user = userEntity
            workspaceEntity.createdAt = workspace.createdAt
            workspaceEntity.modifiedAt = workspace.modifiedAt
            workspaceEntity.title = workspace.title
            
            return true
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func read(id: UUID) throws -> User? {
        do {
            guard let userEntity = try getEntity(id: id) else {
                return nil
            }
            
            let user = User(id: userEntity.id, createdAt: userEntity.createdAt, modifiedAt: userEntity.modifiedAt)
            return user
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readAll() throws -> [User]? {
        let entities = try self.getEntities()
        
        return entities.map {
            User(id: $0.id, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt)
        }
    }
    
    func delete(user: User) throws {
        do {
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", user.id.uuidString)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            
            try moc.execute(deleteRequest)
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    private func getEntity(id: UUID) throws -> UserEntity? {
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
    
    private func getEntities() throws -> [UserEntity] {
        do {
            
            let fetchRequest = UserEntity.fetchRequest()
            let users = try moc.fetch(fetchRequest)
            return users
            
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
}
