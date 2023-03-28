//
//  LabelLinkEntity.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

public class LabelLinkEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LabelLinkEntity> {
        return NSFetchRequest<LabelLinkEntity>(entityName: "LabelLinkEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var document: UUID
    @NSManaged public var workspace: UUID
    @NSManaged public var label: UUID
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension LabelLinkEntity : Comparable {
    public static func < (lhs: LabelLinkEntity, rhs: LabelLinkEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    static public func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> LabelLinkEntity? {
        do {
            let fetchRequest = LabelLinkEntity.fetchRequest()
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

