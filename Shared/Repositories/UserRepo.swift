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

//    func create(workspace: Workspace, for user: User) -> Bool {
//        do {
//            guard let userEntity = try UserEntity.getEntity(id: user.id, moc: moc) else {
//                return false
//            }
//            
//            let workspaceEntity = WorkspaceEntity(entity: WorkspaceEntity.entity(), insertInto: moc)
//            workspaceEntity.id = workspace.id
//            workspaceEntity.user = userEntity
//            workspaceEntity.createdAt = workspace.createdAt
//            workspaceEntity.modifiedAt = workspace.modifiedAt
//            workspaceEntity.title = workspace.title
//            workspaceEntity.labels = NSSet(array: workspace.labels.map {
//                let labelEntity = LabelEntity(entity: LabelEntity.entity(), insertInto: moc)
//                labelEntity.id = $0.id
//                labelEntity.title = $0.title
//                labelEntity.createdAt = $0.createdAt
//                labelEntity.modifiedAt = $0.modifiedAt
//                labelEntity.color = $0.color.rawValue
//                labelEntity.workspace = workspaceEntity
//                return labelEntity
//            })
//            
//            try moc.save()
//            
//            return true
//            
//        } catch let error {
//            print(error)
//            return false
//        }
//    }
    
    func read(id: String) -> User? {
        do {
            guard let userEntity = try getEntity(id: id) else {
                return nil
            }
            
            let user = User(
                id: userEntity.id,
                email: userEntity.email,
                givenName: userEntity.givenName,
                familyName: userEntity.familyName,
                createdAt: userEntity.createdAt,
                modifiedAt: userEntity.modifiedAt
            )
            return user
            
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func readAll() throws -> [User]? {
        let entities = try self.getEntities()
        
        return entities.map {
            User(
                id: $0.id,
                email: $0.email,
                givenName: $0.givenName,
                familyName: $0.familyName,
                createdAt: $0.createdAt,
                modifiedAt: $0.modifiedAt
            )
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
    
    private func getEntity(id: String) throws -> UserEntity? {
        do {
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
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
