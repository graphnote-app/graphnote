//
//  Workspace.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

struct Workspace {
    let id: UUID
    let title: String
    let createdAt: Date
    let modifiedAt: Date
    let user: User
    let labels: [Label]
}
