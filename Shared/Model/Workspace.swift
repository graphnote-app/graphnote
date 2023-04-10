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
    
    let id: String
    let title: String
    let createdAt: Date
    let modifiedAt: Date
    let user: User
    let labels: [Label]
    let documents: [Document]
}
