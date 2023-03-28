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
    
    func create(document: Document, in workspace: Workspace, for user: User) throws -> Bool {
        do {
            guard let workspaceEntity = try WorkspaceEntity.getEntity(id: workspace.id, moc: moc),
                  let userEntity = try UserEntity.getEntity(id: user.id, moc: moc) else {
                return false
            }
            
            let documentEntity = DocumentEntity(entity: DocumentEntity.entity(), insertInto: moc)
            documentEntity.id = document.id
            documentEntity.createdAt = document.createdAt
            documentEntity.modifiedAt = document.modifiedAt
            documentEntity.title = document.title
            documentEntity.workspace = workspaceEntity
            documentEntity.user = userEntity
            
            try? moc.save()
            
            return true

        } catch let error {
            print(error)
            throw error
        }
    }
    
    func create(label: Label, in workspace: Workspace, for user: User) throws -> Bool {
        do {
            guard let workspaceEntity = try WorkspaceEntity.getEntity(id: workspace.id, moc: moc) else {
                return false
            }
            
            let labelEntity = LabelEntity(entity: LabelEntity.entity(), insertInto: moc)
            labelEntity.id = label.id
            labelEntity.createdAt = label.createdAt
            labelEntity.modifiedAt = label.modifiedAt
            labelEntity.title = label.title
            labelEntity.colorRed = Float(NSColor(label.color).redComponent)
            labelEntity.colorGreen = Float(NSColor(label.color).greenComponent)
            labelEntity.colorBlue = Float(NSColor(label.color).blueComponent)
            labelEntity.workspace = workspaceEntity
            
            try? moc.save()
            
            return true

        } catch let error {
            print(error)
            throw error
        }
    }
    
    func readAll() throws -> [Workspace] {
        do {
            let fetchRequest = WorkspaceEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "user.id == %@", user.id.uuidString)
            let workspaces = try moc.fetch(fetchRequest)
            return workspaces.map { workspaceEntity in
                let labels = (workspaceEntity.labels.allObjects as! [LabelEntity]).map { (labelEntity: LabelEntity) in
                    return Label(id: labelEntity.id, title: labelEntity.title, color: Color(red: Double(labelEntity.colorRed), green: Double(labelEntity.colorGreen), blue: Double(labelEntity.colorBlue)), workspaceId: labelEntity.workspace.id, createdAt: labelEntity.createdAt, modifiedAt: labelEntity.modifiedAt)
                }
                
                return Workspace(id: workspaceEntity.id, title: workspaceEntity.title, createdAt: workspaceEntity.createdAt, modifiedAt: workspaceEntity.modifiedAt, user: user, labels: labels, documents: (workspaceEntity.documents.allObjects as! [DocumentEntity]).map {
                    Document(id: $0.id, title: $0.title, createdAt: $0.createdAt, modifiedAt: $0.modifiedAt)
                })
            }
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func read(document: UUID) throws -> Document? {
        do {
            guard let documentEntity = try DocumentEntity.getEntity(id: document, moc: moc) else {
                return nil
            }
            
            let document = Document(id: documentEntity.id, title: documentEntity.title, createdAt: documentEntity.createdAt, modifiedAt: documentEntity.modifiedAt)
            return document
            
        } catch let error {
            print(error)
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
            
            try? moc.save()
        } catch let error {
            print(error)
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
            throw error
        }
    }
}
