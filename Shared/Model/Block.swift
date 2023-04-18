//
//  Block.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

struct Block: Codable {
    let id: UUID
    let type: BlockType
    let content: String
    let createdAt: Date
    let modifiedAt: Date
    let document: Document
}
