//
//  Label.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import SwiftUI

struct Label: Equatable, Hashable, Codable {
    static public func == (lhs: Label, rhs: Label) -> Bool {
        return lhs.id == rhs.id || lhs.title == rhs.title
    }
    
    let id: UUID
    let title: String
    let color: LabelPalette
    let workspace: UUID
    let user: String
    let createdAt: Date
    let modifiedAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(workspace)
        hasher.combine(title)
    }
    
    init(id: UUID, title: String, color: LabelPalette, workspace: UUID, user: String, createdAt: Date, modifiedAt: Date) {
        self.id = id
        self.title = title
        self.color = color
        self.workspace = workspace
        self.user = user
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    init(from: LabelEntity) throws {
        self.id = from.id
        self.title = from.title
        self.color = LabelPalette(rawValue: from.color)!
        self.workspace = from.workspace!.id
        self.user = from.user!.id
        self.createdAt = from.createdAt
        self.modifiedAt = from.modifiedAt
    }

}
