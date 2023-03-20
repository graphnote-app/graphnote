//
//  ContentViewVM.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import Foundation
import SwiftUI

class ContentViewVM: ObservableObject {
    @Published var selectedDocument: String = ""
    @Published var selectedDocumentLabels: [String] = ["WIP", "4.20"]
}
