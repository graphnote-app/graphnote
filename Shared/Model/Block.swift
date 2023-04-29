//
//  Block.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

enum BlockError: Error {
    case documentParseFailed
    case noDocument
}

struct Block: Codable {
    let id: UUID
    let type: BlockType
    let content: String
    let prev: UUID?
    let next: UUID?
    let createdAt: Date
    let modifiedAt: Date
    let document: Document
    
    init(id: UUID, type: BlockType, content: String, prev: UUID?, next: UUID?, createdAt: Date, modifiedAt: Date, document: Document) {
        self.id = id
        self.type = type
        self.content = content
        self.prev = prev
        self.next = next
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.document = document
    }
    
    init(from: BlockEntity) throws {
        do {
            if let document = from.document {
                self.id = from.id
                self.type = BlockType(rawValue: from.type)!
                self.content = from.content
                self.prev = from.prev
                self.next = from.next
                self.createdAt = from.createdAt
                self.modifiedAt = from.modifiedAt
                self.document = try Document(from: document)
            } else {
                throw BlockError.noDocument
            }
        } catch let error {
            #if DEBUG
            fatalError(error.localizedDescription)
            #endif
            throw BlockError.documentParseFailed
        }
    }
}

