//
//  ColorEntity.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

public class ColorEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ColorEntity> {
        return NSFetchRequest<ColorEntity>(entityName: "ColorEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var r: Double
    @NSManaged public var g: Double
    @NSManaged public var b: Double
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension ColorEntity : Comparable {
    public static func < (lhs: ColorEntity, rhs: ColorEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}
