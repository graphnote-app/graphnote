//
//  DocumentViewVM.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

class DocumentViewVM: ObservableObject {
    private func getLastIndex(user: User, workspace: Workspace, document: Document) -> Block? {
        return DataService.shared.getLastBlock(user: user, workspace: workspace, document: document)
    }
    
    @Published var documents: [Document] = []
    
    func fetchDocuments(user: User, workspace: Workspace) {
        do {
            let repo = DocumentRepo(user: user, workspace: workspace)
            let docs = try repo.readAll()
            documents = docs
        } catch let error {
            print(error)
        }
    }
}
