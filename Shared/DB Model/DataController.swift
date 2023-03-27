//
//  DataController.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/25/22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Graphnote")
    
    static let shared = DataController()
    
    private init() {
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func dropDatabase() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! self.container.viewContext.execute(deleteRequest)
        try! self.container.viewContext.save()
    }
}
