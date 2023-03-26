//
//  Block.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

struct Block {
    let id: UUID
    let type: String
    let content: String
    let createdAt: Date
    let modifiedAt: Date
    let document: Document
}
