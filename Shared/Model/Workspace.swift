//
//  Workspace.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/13/22.
//

import Foundation
import CoreData

public class Workspace: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Workspace> {
        return NSFetchRequest<Workspace>(entityName: "Workspace")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var documents: NSSet?
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension Workspace : Comparable {
    public static func < (lhs: Workspace, rhs: Workspace) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}
