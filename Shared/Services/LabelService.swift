//
//  LabelService.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/3/23.
//

import SwiftUI

struct LabelService {
    let user: User
    let workspace: Workspace
    
    func addLabel(title: String, color: LabelPalette, document: Document) throws -> Bool {
        let labelRepo = LabelRepo(user: user, workspace: workspace)
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        var label = Label(id: UUID(), title: title, color: color, workspace: workspace.id, user: user.id, createdAt: Date.now, modifiedAt: Date.now)
        
        let existingLabelUUID = try? labelRepo.exists(label: label)

        if let existingLabelUUID {
            do {
                if let existingLabel = try labelRepo.read(id: existingLabelUUID) {
                    label = existingLabel
                }
            } catch let error {
                print(error)
                throw error
            }
            
            let labelAttachmentExists = try documentRepo.attachExists(label: label, document: document)
            if labelAttachmentExists {
                print("Attachment exists and label exists")
                return false
            } else {
                try DataService.shared.attachLabel(user: user, label: label, document: document, workspace: workspace)
                return true
            }

        } else {
            try DataService.shared.createLabel(user: user, label: label, workspace: workspace)
            try DataService.shared.attachLabel(user: user, label: label, document: document, workspace: workspace)
            return true
        }
        
    }
}
