//
//  Workspaces.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/9/22.
//

import Foundation
import CoreData

final class Workspaces: ObservableObject {
    private let dataController = DataController()

    @Published var items: [Workspace] = []
    
    init() {
        fetchWorkspaces()
    }
    
    func fetchWorkspaces() {
        let fetchRequest: NSFetchRequest<Workspace>
        fetchRequest = Workspace.fetchRequest()
        let context = dataController.container.viewContext
        if let workspaces = try? context.fetch(fetchRequest) {
            self.items = workspaces
        }
    }
}
