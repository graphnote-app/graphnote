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
        return NSFetchRequest<BlockEntity>(entityName: "Block")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
    @NSManaged public var document: DocumentEntity
}

extension BlockEntity : Comparable {
    public static func < (lhs: BlockEntity, rhs: BlockEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

