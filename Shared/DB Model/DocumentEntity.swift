//
//  DocumentEntity.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/13/22.
//

import Foundation
import CoreData

public class DocumentEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<DocumentEntity> {
        return NSFetchRequest<DocumentEntity>(entityName: "DocumentEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var workspace: WorkspaceEntity
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
    @NSManaged public var user: UserEntity
}

extension DocumentEntity : Comparable {
    public static func < (lhs: DocumentEntity, rhs: DocumentEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    static public func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> DocumentEntity? {
        do {
            let fetchRequest = DocumentEntity.fetchRequest()
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
