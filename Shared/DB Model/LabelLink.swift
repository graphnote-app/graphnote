//
//  LabelLink.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

public class LabelLink: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LabelLink> {
        return NSFetchRequest<LabelLink>(entityName: "LabelLink")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var document: DocumentEntity
    @NSManaged public var label: LabelEntity
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension LabelLink : Comparable {
    public static func < (lhs: LabelLink, rhs: LabelLink) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    static public func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> LabelLink? {
        do {
            let fetchRequest = LabelLink.fetchRequest()
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

