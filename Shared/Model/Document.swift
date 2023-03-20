//
//  Document.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/13/22.
//

import Foundation
import CoreData

public class Document: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var workspace: Workspace
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension Document : Comparable {
    public static func < (lhs: Document, rhs: Document) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}
