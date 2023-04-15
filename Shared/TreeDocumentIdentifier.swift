//
//  TreeDocumentIdentifier.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/9/22.
//

import Foundation

struct TreeDocumentIdentifier: Equatable {
    let label: UUID
    let document: UUID
    let workspace: UUID
}
