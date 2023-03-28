//
//  LabelLink.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/27/23.
//

import Foundation

struct LabelLink {
    let id: UUID
    let label: UUID
    let document: UUID
    let workspace: UUID
    let createdAt: Date
    let modifiedAt: Date
}
