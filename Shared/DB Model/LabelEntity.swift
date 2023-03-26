//
//  LabelEntity.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

public class LabelEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LabelEntity> {
        return NSFetchRequest<LabelEntity>(entityName: "LabelEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var color: ColorEntity
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension LabelEntity : Comparable {
    public static func < (lhs: LabelEntity, rhs: LabelEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

