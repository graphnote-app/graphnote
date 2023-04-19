//
//  WorkspaceRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import SwiftUI
import CoreData

struct WorkspaceRepo {
    
    let user: User
    
    private let moc = DataController.shared.container.viewContext
    
    func create(workspace: Workspace) -> Bool {
        do {
            let workspaceEntity = WorkspaceEntity(entity: WorkspaceEntity.entity(), insertInto: moc)
            
            guard let userEntity = try UserEntity.getEntity(id: user.id, moc: moc) else {
                return false
            }
            
            workspaceEntity.id = workspace.id
            workspaceEntity.user = userEntity
            workspaceEntity.title = workspace.title
            workspaceEntity.labels = NSSet(array: workspace.labels)
            workspaceEntity.documents = NSSet(array: workspace.documents)
            workspaceEntity.createdAt = workspace.createdAt
            workspaceEntity.modifiedAt = workspace.modifiedAt
            
            try moc.save()
            
            return true

        } catch let error {
            print(error)
            return false
        }
    }
    
    func create(document: Document) -> Bool {
        do {
            print(document)
            guard let workspaceEntity = try WorkspaceEntity.getEntity(id: document.workspace, moc: moc) else {
                print("Couldn't get WorkspaceEntity")
                return false
            }
            
            guard let userEntity = try UserEntity.getEntity(id: user.id, moc: moc) else {
                print("Couldn't get UserEntity")
                return false
            }
            
            let documentEntity = DocumentEntity(entity: DocumentEntity.entity(), insertInto: moc)
            documentEntity.id = document.id
            documentEntity.createdAt = document.createdAt
            documentEntity.modifiedAt = document.modifiedAt
            documentEntity.title = document.title
            documentEntity.workspace = workspaceEntity
            documentEntity.user = userEntity
            
            try moc.save()
            
            return true

        } catch let error {
            print(error)
            return false
        }
    }
    
//    func create(label: Label) -> Bool {
//        do {
//            guard let workspaceEntity = try WorkspaceEntity.getEntity(id: label.workspace, moc: moc) else {
//                print("NO WORKSPACE")
//                return false
//            }
//            
//            guard let userEntity = try UserEntity.getEntity(id: label.user, moc: moc) else {
//                print("NO USER")
//                return false
//            }
//            
//            let labelEntity = LabelEntity(entity: LabelEntity.entity(), insertInto: moc)
//            labelEntity.id = label.id
//            labelEntity.createdAt = label.createdAt
//            labelEntity.modifiedAt = label.modifiedAt
//            labelEntity.title = label.title
//            labelEntity.color = label.color.rawValue
//            labelEntity.workspace = workspaceEntity
//            labelEntity.user = userEntity
//            
//            try moc.save()
//            
//            return true
//
//        } catch let error {
//            print(error)
//            return false
//        }
//    }
    
    func readAll() throws -> [Workspace] {
        do {
            let fetchRequest = WorkspaceEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user.id == %@", user.id)
            let workspaces = try moc.fetch(fetchRequest)
            return workspaces.map { workspaceEntity in
                let labels: [Label] = (workspaceEntity.labels.allObjects as! [LabelEntity]).compactMap { (labelEntity: LabelEntity) in
                    if let workspace = labelEntity.workspace, let user = labelEntity.user {
                        return Label(id: labelEntity.id, title: labelEntity.title, color: LabelPalette(rawValue: labelEntity.color)!, workspace: workspace.id, user: user.id, createdAt: labelEntity.createdAt, modifiedAt: labelEntity.modifiedAt)
                    } else {
                        print("workspace / user is nil: \(labelEntity.workspace) \(labelEntity.user)")
                        return nil
                    }
                }
                
                return Workspace(id: workspaceEntity.id, title: workspaceEntity.title, createdAt: workspaceEntity.createdAt, modifiedAt: workspaceEntity.modifiedAt, user: user.id, labels: labels, documents: (workspaceEntity.documents.allObjects as! [DocumentEntity]).compactMap {
                    if let workspace = $0.workspace {
                        return Document(id: $0.id, title: $0.title, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt, workspace: workspace.id)
                    } else {
                        print("workspace is nil")
                        return nil
                    }
                })
            }
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func read(workspace: UUID) throws -> Workspace? {
        do {
            guard let workspaceEntity = try WorkspaceEntity.getEntity(id: workspace, moc: moc) else {
                print("worksace entity does not exists")
                return nil
            }
        
            let labels = (workspaceEntity.labels.allObjects as! [LabelEntity]).compactMap { (labelEntity: LabelEntity) in
                if let user = labelEntity.user, let workspace = labelEntity.workspace {
                    return Label(id: labelEntity.id, title: labelEntity.title, color: LabelPalette(rawValue: labelEntity.color)!, workspace: workspace.id, user: user.id, createdAt: labelEntity.createdAt, modifiedAt: labelEntity.modifiedAt)
                } else {
                    print("user or workspace is nil: \(labelEntity.user) \(labelEntity.workspace)")
                    return nil
                }
            }
            
            return Workspace(id: workspaceEntity.id, title: workspaceEntity.title, createdAt: workspaceEntity.createdAt, modifiedAt: workspaceEntity.modifiedAt, user: user.id, labels: labels, documents: (workspaceEntity.documents.allObjects as! [DocumentEntity]).compactMap {
                if let workspace = $0.workspace {
                    return Document(id: $0.id, title: $0.title, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt, workspace: workspace.id)
                } else {
                    print("workspace is nil")
                    return nil
                }
            })
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func read(document: UUID, workspace: UUID) throws -> Document? {
        do {
            guard let documentEntity = try DocumentEntity.getEntity(id: document, moc: moc) else {
                return nil
            }
            
            guard let workspace = documentEntity.workspace else {
                return nil
            }
            
            let document = Document(id: documentEntity.id, title: documentEntity.title, createdAt: documentEntity.createdAt, modifiedAt: documentEntity.modifiedAt, workspace: workspace.id)
            return document
            
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
            throw error
        }
    }
    
    func update(workspace: Workspace) throws {
        do {
            guard let workspaceEntity = try WorkspaceEntity.getEntity(id: workspace.id, moc: moc) else {
                return
            }
            
            workspaceEntity.title = workspace.title
            workspaceEntity.createdAt = workspace.createdAt
            workspaceEntity.modifiedAt = workspace.modifiedAt
            
            try moc.save()
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
            throw error
        }
    }
    
    func delete(workspace: Workspace) throws {
        do {
            let fetchRequest = WorkspaceEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", workspace.id.uuidString)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
            
            try moc.execute(deleteRequest)
            
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
            throw error
        }
        
    }
    
    func readLabelLinks(workspace: Workspace) throws -> [LabelLink] {
        do {
            let fetchRequest = LabelLinkEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "workspace == %@", workspace.id.uuidString)
            let labelLinksEntities = try moc.fetch(fetchRequest)
            return labelLinksEntities.map {
                LabelLink(id: $0.id, label: $0.label, document: $0.document, workspace: $0.workspace, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt)
            }
            
        } catch let error {
            print(error)
            fatalError()
            throw error
        }
    }
}
