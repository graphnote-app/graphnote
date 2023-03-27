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
        let labelEntity = LabelEntity(entity: LabelEntity.entity(), insertInto: moc)
        labelEntity.title = label.title
        labelEntity.id = label.id
        labelEntity.modifiedAt = label.modifiedAt
        labelEntity.createdAt = label.createdAt
        
        let rgb = NSColor(label.color).cgColor.components
        labelEntity.colorRed = Float(rgb![0])
        labelEntity.colorGreen = Float(rgb![1])
        labelEntity.colorBlue = Float(rgb![2])
        
        try? moc.save()
        return true
    }

}
