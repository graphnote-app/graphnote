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
    
    @Published private(set) var loaded = false
    
    static let shared = DataController()
    
    private init() {
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        self.load()
    }
    
    private func load() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                self.loaded = false
            }
            
            self.loaded = true
        }
    }
    
    func dropDatabase() {
        softCleanDatabase()
    }
    
    func dropTable(fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try! self.container.viewContext.execute(deleteRequest)
        try! self.container.viewContext.save()
    }
    
    func softCleanDatabase() {
//        dropTable(fetchRequest: UserEntity.fetchRequest())
        dropTable(fetchRequest: WorkspaceEntity.fetchRequest())
        dropTable(fetchRequest: DocumentEntity.fetchRequest())
        dropTable(fetchRequest: BlockEntity.fetchRequest())
        dropTable(fetchRequest: LabelEntity.fetchRequest())
        dropTable(fetchRequest: LabelLinkEntity.fetchRequest())
        dropTable(fetchRequest: SyncMessageEntity.fetchRequest())
        dropTable(fetchRequest: SyncMessageIDEntity.fetchRequest())
        dropTable(fetchRequest: LastSyncTimeEntity.fetchRequest())
    }
    
}
