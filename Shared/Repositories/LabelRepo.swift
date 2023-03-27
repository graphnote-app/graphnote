//
//  LabelRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import CoreData
import Cocoa

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
        
        let rgb = NSColor(label.color).cgColor.components
        labelEntity.colorRed = Float(rgb![0])
        labelEntity.colorGreen = Float(rgb![1])
        labelEntity.colorBlue = Float(rgb![2])
        
        try? moc.save()
        return true
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
