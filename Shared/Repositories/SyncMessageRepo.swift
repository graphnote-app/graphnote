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
    
    func has(id: UUID) -> Bool {
        do {
            let fetchRequest = SyncMessageEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
            guard let syncMessage = try moc.fetch(fetchRequest).first else {
                return false
            }
            return syncMessage.id == id            
        } catch let error {
            print(error)
            return false
        }
    }
    
//    func setSyncedOnMessageID(id: UUID) throws {
//        do {
//            guard let messageEntity = try SyncMessageIDEntity.getEntity(id: id, moc: moc) else {
//                // Add throw error here
//                fatalError()
//                return
//            }
//
//            messageEntity.isSynced = true
//
//            try moc.save()
//
//        } catch let error {
//            print(error)
//            throw error
//        }
//    }
    
    func readAllIDsNotApplied() -> [UUID]? {
        do {
            let fetchRequest = SyncMessageIDEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "isApplied == %@", NSNumber(value: false))
            let syncMessageIDs = try moc.fetch(fetchRequest)
            return syncMessageIDs.map {$0.id}
                
        } catch let error {
            print(error)
            return nil
        }
    }
    
    func create(id: UUID) throws {
        do {

            let syncMessageIdEntity = SyncMessageIDEntity(entity: SyncMessageIDEntity.entity(), insertInto: moc)
            syncMessageIdEntity.id = id
            syncMessageIdEntity.isSynced = false
            
            try moc.save()
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func create(message: SyncMessage) throws {
        do {
            let encoder = JSONEncoder()
            
            if let data = try? encoder.encode(message.contents) {
                let messageEntity = SyncMessageEntity(entity: SyncMessageEntity.entity(), insertInto: moc)
                messageEntity.id = message.id
                messageEntity.user = message.user
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
    
    private func fetchLastSyncTime() throws -> LastSyncTimeEntity? {
        do {
            let fetchRequest = LastSyncTimeEntity.fetchRequest()
            guard let lastSyncTimeEntity = try moc.fetch(fetchRequest).first else {
                return nil
            }
            
            return lastSyncTimeEntity
                
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func setLastSyncTime(time: Date?) throws {
        do {
            
            if let lastSyncTimeEntity = try? fetchLastSyncTime() {
                // Update
                lastSyncTimeEntity.lastSyncTime = time ?? Date.now
            } else {
                // Create
                let messageEntity = LastSyncTimeEntity(entity: LastSyncTimeEntity.entity(), insertInto: moc)
                messageEntity.lastSyncTime = time ?? Date.now
            }
                        
            try moc.save()

        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readLastSyncTime() throws -> Date? {
        try? fetchLastSyncTime()?.lastSyncTime
    }
    
    func readAllWhere(isSynced: Bool) throws -> [SyncMessage] {
        do {
            let fetchRequest = SyncMessageEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user == %@ && isSynced == %@", user.id, NSNumber(value: isSynced))
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
                fatalError("message not found to update")
            }
            
            messageEntity.isSynced = true
            
            try moc.save()
            
        } catch let error {
            print(error)
            throw error
        }
    }
}
