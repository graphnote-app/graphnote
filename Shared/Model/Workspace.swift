//
//  Workspace.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

public struct Workspace: Equatable {
    public static func == (lhs: Workspace, rhs: Workspace) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: UUID
    public let title: String
    public let createdAt: Date
    public let modifiedAt: Date
    public let user: User
    public let labels: [Label]
    public let documents: [Document]
}
