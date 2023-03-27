//
//  Label.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation
import SwiftUI

struct Label: Equatable, Hashable {
    static func == (lhs: Label, rhs: Label) -> Bool {
        return lhs.id == rhs.id || lhs.title == rhs.title
    }
    
    let id: UUID
    let title: String
    let color: Color
    let workspaceId: UUID
    let createdAt: Date
    let modifiedAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(workspaceId)
        hasher.combine(title)
    }
    

}
