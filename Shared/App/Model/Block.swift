//
//  Block.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/11/23.
//

import Foundation
import CoreData

public class Block: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Block> {
        return NSFetchRequest<Block>(entityName: "Block")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var type: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
    @NSManaged public var document: Document
}

extension Block : Comparable {
    public static func < (lhs: Block, rhs: Block) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

