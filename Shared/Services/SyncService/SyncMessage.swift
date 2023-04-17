//
//  SyncMessageType.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/6/23.
//

import Foundation

enum SyncMessageType: String, Codable {
    case user
    case workspace
    case document
    case label
    case labelLink
}

enum SyncMessageAction: String, Codable {
    case create
    case read
    case update
    case delete
}

struct SyncMessage: Codable {
    let id: UUID
    let user: String
    let timestamp: Date
    let type: SyncMessageType
    let action: SyncMessageAction
    let isSynced: Bool
    let isApplied: Bool
    let contents: String
}

struct SyncMessageIDsResult: Codable {
    let lastSyncTime: Double
    let ids: [String]
}
