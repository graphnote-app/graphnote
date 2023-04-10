//
//  Document.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

public struct Document: Equatable, Codable, Hashable {
    public let id: UUID
    public let title: String
    public let createdAt: Date
    public let modifiedAt: Date
    public let workspace: UUID
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(workspace)
    }
}
