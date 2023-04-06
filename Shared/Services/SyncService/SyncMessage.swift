//
//  SyncMessageType.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/6/23.
//

import Foundation

enum SyncMessageType: String, Codable {
    case createUser
}

struct SyncMessage: Codable {
    let id: UUID
    let timestamp: Date
    let type: SyncMessageType
    let contents: String
}
