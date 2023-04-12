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
        
        var label = Label(id: UUID(), title: title, color: color, workspaceId: workspace.id, createdAt: .now, modifiedAt: .now)
        
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
            
            if let labelAttachmentExists = try? documentRepo.attachExists(label: label, document: document) {
                if labelAttachmentExists {
                    print("Attachment exists and label exists")
                    return false
                } else {
                    documentRepo.attach(label: label, document: document)
                    return true
                }
            } else {
                return false
            }
            
        } else {
            _ = try? labelRepo.create(label: label)
            documentRepo.attach(label: label, document: document)
            return true
        }
        
    }
}
