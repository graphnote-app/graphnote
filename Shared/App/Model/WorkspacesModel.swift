//
//  WorkspacesModel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/6/22.
//

import Foundation
import Combine
import CoreData
import SwiftUI

final class WorkspacesModel: ObservableObject {
    @Published var items: [WorkspaceModel] = []
    let dataController = DataController()
    
    init() {
        fetchWorkspaces()
    }
    
    func fetchWorkspaces() {
        let fetchRequest: NSFetchRequest<Workspace>
        fetchRequest = Workspace.fetchRequest()
        let context = dataController.container.viewContext
        if let workspaces = try? context.fetch(fetchRequest) {
            self.items = workspaces.map {
                return WorkspaceModel(
                    id: $0.id!,
                    title: $0.title!,
                    documents: DocumentsModel(workspaceId: $0.id!)
                )
            }
        }
    }
    
}
