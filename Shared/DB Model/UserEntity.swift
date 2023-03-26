//
//  UserEntity.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import CoreData

public class UserEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension UserEntity : Comparable {
    public static func < (lhs: UserEntity, rhs: UserEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}
