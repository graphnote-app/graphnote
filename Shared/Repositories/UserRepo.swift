//
//  UserRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

struct UserRepo {
    
    static private let moc = DataController.shared.container.viewContext
    static private let fetchRequest = UserEntity.fetchRequest()
    
    static func create(user: User) throws {
        do {
            let userEntity = UserEntity(entity: UserEntity.entity(), insertInto: moc)
            userEntity.id = user.id
            try moc.save()
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    static func read(id: UUID) throws -> User? {
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
    
    static func readAll() throws -> [User]? {
        let entities = try self.getEntities()
        
        return entities.map {
            User(id: $0.id, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt)
        }
    }
    
    static func delete(user: User) throws {
        do {
            fetchRequest.predicate = NSPredicate(format: "id == %@", user.id.uuidString)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            
            try moc.execute(deleteRequest)
            try moc.save()
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    static private func getEntity(id: UUID) throws -> UserEntity? {
        do {
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
    
    static private func getEntities() throws -> [UserEntity] {
        do {
            
            let users = try moc.fetch(fetchRequest)
            return users
            
        } catch let error {
            print(error)
            throw error
        }
    }
}
