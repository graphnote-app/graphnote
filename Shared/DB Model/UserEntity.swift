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
    
    @NSManaged public var id: String
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension UserEntity : Comparable {
    public static func < (lhs: UserEntity, rhs: UserEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    static public func getEntity(id: String, moc: NSManagedObjectContext) throws -> UserEntity? {
        do {
            let fetchRequest = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
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


