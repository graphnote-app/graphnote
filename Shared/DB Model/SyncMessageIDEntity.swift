//
//  SyncMessageIDEntity.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/8/23.
//

import CoreData

public class SyncMessageIDEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SyncMessageIDEntity> {
        return NSFetchRequest<SyncMessageIDEntity>(entityName: "SyncMessageIDEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var isSynced: Bool
    @NSManaged public var isApplied: Bool
}

extension SyncMessageIDEntity {
    static public func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> SyncMessageIDEntity? {
        do {
            let fetchRequest = SyncMessageIDEntity.fetchRequest()
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
