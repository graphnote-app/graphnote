//
//  LabelEntity.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData

class LabelEntity: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LabelEntity> {
        return NSFetchRequest<LabelEntity>(entityName: "LabelEntity")
    }
    
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var color: String
    @NSManaged var workspace: WorkspaceEntity
    @NSManaged var createdAt: Date
    @NSManaged var modifiedAt: Date
}

extension LabelEntity : Comparable {
    static func < (lhs: LabelEntity, rhs: LabelEntity) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
    
    static func getEntity(id: UUID, moc: NSManagedObjectContext) throws -> LabelEntity? {
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
    
    static func getEntity(title: String, workspace: Workspace, moc: NSManagedObjectContext) throws -> LabelEntity? {
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

