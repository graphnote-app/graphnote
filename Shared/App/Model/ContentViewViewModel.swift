//
//  ContentViewViewModel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/13/22.
//

import Foundation
import CoreData

final class ContentViewViewModel: ObservableObject {
    let moc: NSManagedObjectContext

    @Published var items: [Workspace] = []
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
        fetchWorkspaces()
    }
    
    func fetchWorkspaces() {
        let fetchRequest: NSFetchRequest<Workspace>
        fetchRequest = Workspace.fetchRequest()
        
        if let workspaces = try? moc.fetch(fetchRequest) {
            self.items = workspaces
        }
    }
}
