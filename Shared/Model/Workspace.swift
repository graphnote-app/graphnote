//
//  Workspace.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

struct Workspace: Equatable, Codable {
    static func == (lhs: Workspace, rhs: Workspace) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: UUID
    let title: String
    let createdAt: Date
    let modifiedAt: Date
    let user: String
    let labels: [Label]
    let documents: [Document]
}
