//
//  LabelRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData
import SwiftUI

enum LabelRepoError: Error {
    case workspaceFailed
    case userFailed
}

struct LabelRepo {
    let user: User
    let workspace: Workspace
    
    private let moc = DataController.shared.container.viewContext
    
    func create(label: Label) throws -> LabelEntity? {
        guard let workspaceEntity = try? getWorkspaceEntity(workspace: workspace) else {
            print("Failed to get workspaceEntity: \(workspace)")
            throw LabelRepoError.workspaceFailed
        }

        if let labelEntity = try? LabelEntity.getEntity(title: label.title, workspace: workspace, moc: moc) {
            return labelEntity
        } else {
            do {
                guard let userEntity = try? UserEntity.getEntity(id: label.user, moc: moc) else {
                    throw LabelRepoError.userFailed
                }
                
                let labelEntity = LabelEntity(entity: LabelEntity.entity(), insertInto: moc)
                labelEntity.title = label.title
                labelEntity.id = label.id
                labelEntity.modifiedAt = label.modifiedAt
                labelEntity.createdAt = label.createdAt
                labelEntity.workspace = workspaceEntity
                labelEntity.color = label.color.rawValue
                labelEntity.user = userEntity
                
                try moc.save()
                return labelEntity
                
            } catch let error {
                print(error)
                return nil
            }
            
        }
    }
    
    func read(id: UUID) throws -> Label? {
        do {
            guard let labelEntity = try LabelEntity.getEntity(id: id, moc: moc) else {
                return nil
            }
            
            if let user = labelEntity.user {
                let label = Label(
                    id: labelEntity.id,
                    title: labelEntity.title,
                    color: LabelPalette(rawValue: labelEntity.color)!,
                    workspace: workspace.id,
                    user: user.id,
                    createdAt: labelEntity.createdAt,
                    modifiedAt: labelEntity.modifiedAt
                )
                return label
                
            } else {
                return nil
            }
            
            
        } catch let error {
            print(error)
            throw error
        }
    }
    
    func exists(label: Label) throws -> UUID? {
        do {
            let fetchRequest = LabelEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@ || id == %@", label.title, label.id.uuidString)
            let result = try moc.fetch(fetchRequest)
            
            if let first = result.first {
                return first.id
            }
            
            return nil
                        
        } catch let error {
            print(error)
            throw error
        }
    }
    
    private func getWorkspaceEntity(workspace: Workspace) throws -> WorkspaceEntity? {
        do {
            let fetchRequest = WorkspaceEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", workspace.id.uuidString)
            guard let user = try moc.fetch(fetchRequest).first else {
                return nil
            }
            
            return user
            
        } catch let error {
            print(error)
            throw error
        }
    }

}
