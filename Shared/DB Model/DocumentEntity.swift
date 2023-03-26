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
        return NSFetchRequest<DocumentEntity>(entityName: "Document")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var workspace: WorkspaceEntity
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension DocumentEntity : Comparable {
    public static func < (lhs: DocumentEntity, rhs: DocumentEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}
