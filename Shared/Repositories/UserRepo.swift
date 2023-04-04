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

    func create(workspace: Workspace, for user: User) throws -> Bool {
        do {
            guard let userEntity = try UserEntity.getEntity(id: user.id, moc: moc) else {
                return false
            }
            
            let workspaceEntity = WorkspaceEntity(entity: WorkspaceEntity.entity(), insertInto: moc)
            workspaceEntity.id = workspace.id
            workspaceEntity.user = userEntity
            workspaceEntity.createdAt = workspace.createdAt
            workspaceEntity.modifiedAt = workspace.modifiedAt
            workspaceEntity.title = workspace.title
            workspaceEntity.labels = NSSet(array: workspace.labels.map {
                let labelEntity = LabelEntity(entity: LabelEntity.entity(), insertInto: moc)
                labelEntity.id = $0.id
                labelEntity.title = $0.title
                labelEntity.createdAt = $0.createdAt
                labelEntity.modifiedAt = $0.modifiedAt
                labelEntity.colorRed = Float(GNColor($0.color).getColorComponents().red)
                labelEntity.colorGreen = Float(GNColor($0.color).getColorComponents().green)
                labelEntity.colorBlue = Float(GNColor($0.color).getColorComponents().blue)
                labelEntity.workspace = workspaceEntity
                return labelEntity
            })
            
            try? moc.save()
            
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
            fetchRequest.predicate = NSPredicate(format: "id == %@", user.id)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            
            try moc.execute(deleteRequest)
            
            try? moc.save()
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
}
