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
    @NSManaged public var documents: NSSet
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
    @NSManaged public var user: UserEntity
    @NSManaged public var labels: NSSet
}

extension WorkspaceEntity : Comparable {
    public static func < (lhs: WorkspaceEntity, rhs: WorkspaceEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    static public func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> WorkspaceEntity? {
        do {
            let fetchRequest = WorkspaceEntity.fetchRequest()
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
