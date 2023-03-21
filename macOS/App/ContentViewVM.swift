//
//  ContentViewVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import Foundation
import SwiftUI

class ContentViewVM: ObservableObject {
    @Published var selectedDocumentTitle: String = "Testing"
    @Published var selectedDocumentLabels: [String] = ["WIP", "4.20", "Bookclub", "Other", "Today", "Stuff"]
    @Published var selectedDocument = DocumentIdentifier(workspaceId: UUID(), documentId: UUID())
}
