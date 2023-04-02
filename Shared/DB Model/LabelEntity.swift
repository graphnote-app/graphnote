//
//  LabelEntity.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

public class LabelEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LabelEntity> {
        return NSFetchRequest<LabelEntity>(entityName: "LabelEntity")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var colorRed: Float
    @NSManaged public var colorGreen: Float
    @NSManaged public var colorBlue: Float
    @NSManaged public var workspace: WorkspaceEntity
    @NSManaged public var createdAt: Date
    @NSManaged public var modifiedAt: Date
}

extension LabelEntity : Comparable {
    public static func < (lhs: LabelEntity, rhs: LabelEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    static public func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> LabelEntity? {
        do {
            let fetchRequest = LabelEntity.fetchRequest()
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
    
    static public func getEntity(title: String, workspace: Workspace, moc: NSManagedObjectContext) throws -> LabelEntity? {
        do {
            let fetchRequest = LabelEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@ && workspace.id == %@", title, workspace.id.uuidString)
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

