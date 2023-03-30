//
//  LabelRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData
import SwiftUI

struct LabelRepo {
    let user: User
    let workspace: Workspace
    
    private let moc = DataController.shared.container.viewContext
    
    func create(label: Label) -> Bool {
        guard let workspaceEntity = try? getWorkspaceEntity(workspace: workspace) else {
            print("Failed to get workspaceEntity: \(workspace)")
            return false
        }
        
        let labelEntity = LabelEntity(entity: LabelEntity.entity(), insertInto: moc)
        labelEntity.title = label.title
        labelEntity.id = label.id
        labelEntity.modifiedAt = label.modifiedAt
        labelEntity.createdAt = label.createdAt
        labelEntity.workspace = workspaceEntity
        
        let rgb = GNColor(label.color).cgColor.components
        labelEntity.colorRed = Float(rgb![0])
        labelEntity.colorGreen = Float(rgb![1])
        labelEntity.colorBlue = Float(rgb![2])
        
        try? moc.save()
        return true
    }
    
    func read(id: UUID) throws -> Label? {
        do {
            guard let labelEntity = try LabelEntity.getEntity(id: id, moc: moc) else {
                return nil
            }
            
            let label = Label(id: labelEntity.id, title: labelEntity.title, color: Color(red: Double(labelEntity.colorRed), green: Double(labelEntity.colorGreen), blue: Double(labelEntity.colorBlue)), workspaceId: labelEntity.workspace.id, createdAt: labelEntity.createdAt, modifiedAt: labelEntity.modifiedAt)
            return label
            
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
