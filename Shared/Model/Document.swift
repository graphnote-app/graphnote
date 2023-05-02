//
//  Document.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

enum DocumentError: Error {
    case noWorkspace
}

public struct Document: Equatable, Codable, Hashable {
    public let id: UUID
    public let title: String
    public let focused: UUID?
    public let createdAt: Date
    public let modifiedAt: Date
    public let workspace: UUID
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(workspace)
    }
    
    public init(id: UUID, title: String, focused: UUID?, createdAt: Date, modifiedAt: Date, workspace: UUID) {
        self.id = id
        self.title = title
        self.focused = focused
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.workspace = workspace
    }
    
    public init(from: DocumentEntity) throws {
        if let workspace = from.workspace {
            self.id = from.id
            self.title = from.title
            self.focused = from.focused
            self.createdAt = from.createdAt
            self.modifiedAt = from.modifiedAt
            self.workspace = workspace.id
        } else {
            throw DocumentError.noWorkspace
        }
    }
}

public struct DocumentUpdate: Codable {
    public let id: UUID
    public let workspace: UUID
    public let content: Dictionary<String, String>
}
