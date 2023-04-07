//
//  SynMessageEntity.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/6/23.
//

import CoreData

public class SyncMessageEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SyncMessageEntity> {
        return NSFetchRequest<SyncMessageEntity>(entityName: "SyncMessageEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var user: String
    @NSManaged public var type: String
    @NSManaged public var action: String
    @NSManaged public var timestamp: Date
    @NSManaged public var contents: Data
    @NSManaged public var isSynced: Bool
}

extension SyncMessageEntity {
    static public func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> SyncMessageEntity? {
        do {
            let fetchRequest = SyncMessageEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
            guard let entity = try moc.fetch(fetchRequest).first else {
                return nil
            }
            
            return entity
            
        } catch let error {
            print(error)
            throw error
        }
    }
}


