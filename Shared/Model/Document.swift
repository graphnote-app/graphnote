//
//  Document.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

struct Document {
    let id: UUID
    let title: String
    let createdAt: Date
    let modifiedAt: Date
    let workspace: Workspace
}
