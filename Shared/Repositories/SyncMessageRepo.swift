//
//  SyncMessageRepo.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/6/23.
//

import Foundation
import CoreData

struct SyncMessageRepo {
    let user: User
    
    private let moc = DataController.shared.container.viewContext
    
    enum SyncMessaegRepoError: Error {
        case contentParseFailed
    }
    
    func create(message: SyncMessage) throws {
        do {
            if let data = message.contents.data(using: .utf8) {
                let messageEntity = SyncMessageEntity(entity: SyncMessageEntity.entity(), insertInto: moc)
                messageEntity.id = message.id
                messageEntity.timestamp = message.timestamp
                messageEntity.type = message.type.rawValue
                messageEntity.action = message.action.rawValue
                messageEntity.contents = data
                messageEntity.isSynced = message.isSynced
                
                try moc.save()
            } else {
                throw SyncMessaegRepoError.contentParseFailed
            }
            
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readAll() throws -> [SyncMessage] {
        do {
            let fetchRequest = SyncMessageEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user == %@", user.id)
            let messageEntities = try moc.fetch(fetchRequest)
            let decoder = JSONDecoder()
            
            return messageEntities.map {
                let contents = try! decoder.decode(String.self, from: $0.contents)
                return SyncMessage(id: $0.id,
                                   user: $0.user,
                                   timestamp: $0.timestamp,
                                   type: SyncMessageType(rawValue: $0.type)!,
                                   action: SyncMessageAction(rawValue: $0.action)!,
                                   isSynced: $0.isSynced,
                                   contents: contents
                )
            }
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func updateToIsSynced(id: UUID) throws {
        do {
            guard let messageEntity = try SyncMessageEntity.getEntity(id: id, moc: moc) else {
                // Add throw error here
                return
            }
            
            messageEntity.isSynced = true
            
            try moc.save()
            
        } catch let error {
            print(error)
            throw error
        }
    }
}
