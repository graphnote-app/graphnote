//
//  TreeViewItem.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/21/23.
//

import Foundation
import SwiftUI

struct TreeViewItem {
    let id: UUID
    let title: String
    let color: Color
    let subItems: [TreeViewSubItem]?
}

struct TreeViewSubItem {
    let id: UUID
    let title: String
}
