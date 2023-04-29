//
//  BlockEntity.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/11/23.
//

import Foundation
import CoreData

public class BlockEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<BlockEntity> {
        return NSFetchRequest<BlockEntity>(entityName: "BlockEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var content: String
    @NSManaged public var prev: UUID?
    @NSManaged public var next: UUID?
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
    @NSManaged public var document: DocumentEntity?
}

extension BlockEntity : Comparable {
    public static func < (lhs: BlockEntity, rhs: BlockEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    static public func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> BlockEntity? {
        do {
            let fetchRequest = BlockEntity.fetchRequest()
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
