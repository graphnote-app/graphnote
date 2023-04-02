//
//  Label.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import SwiftUI

public struct Label: Equatable, Hashable {
    static public func == (lhs: Label, rhs: Label) -> Bool {
        return lhs.id == rhs.id || lhs.title == rhs.title
    }
    
    public let id: UUID
    public let title: String
    public let color: Color
    public let workspaceId: UUID
    public let createdAt: Date
    public let modifiedAt: Date
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(workspaceId)
        hasher.combine(title)
    }
    

}
