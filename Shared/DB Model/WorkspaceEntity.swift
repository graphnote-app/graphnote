//
//  WorkspaceEntity.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/13/22.
//

import Foundation
import CoreData

public class WorkspaceEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkspaceEntity> {
        return NSFetchRequest<WorkspaceEntity>(entityName: "WorkspaceEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var documents: NSSet?
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension WorkspaceEntity : Comparable {
    public static func < (lhs: WorkspaceEntity, rhs: WorkspaceEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}
