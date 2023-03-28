//
//  LabelLinkRepo.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/28/23.
//

import Foundation
import CoreData
import Cocoa
import SwiftUI

struct LabelLinkRepo {
    let user: User
    let workspace: Workspace
    
    private let moc = DataController.shared.container.viewContext
    
    func readAll(document: Document) throws -> [LabelLink]? {
        do {
            let fetchRequest = LabelLinkEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "document == %@", document.id.uuidString)
            let labelLinkEntities = try moc.fetch(fetchRequest)
            return labelLinkEntities.map { labelLinkEntity in
                return LabelLink(
                    id: labelLinkEntity.id,
                    label: labelLinkEntity.label,
                    document: labelLinkEntity.document,
                    workspace: labelLinkEntity.workspace,
                    createdAt: labelLinkEntity.createdAt,
                    modifiedAt: labelLinkEntity.modifiedAt
                )
            }
        } catch let error {
            print(error)
            throw error
        }
    }
}
