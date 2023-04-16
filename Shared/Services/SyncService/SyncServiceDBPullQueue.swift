//
//  SyncServiceDBPullQueue.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/15/23.
//

import Foundation

class SyncServiceDBPullQueue {
    let user: User
    
    private var queue = [UUID]()
    
    private lazy var syncMessageRepo = {
        return SyncMessageRepo(user: user)
    }()
    
    init(user: User) {
        self.user = user
        self.queue = []
        
        // Read from the database to the queue
        fetchQueue()
    }
    
    func add(id: UUID) -> Bool {
        // Add to DB
        do {
            try syncMessageRepo.create(id: id)
            // Add to runtime queue if successful
            self.queue.append(id)
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    func remove(id: UUID) -> Bool {
        // remove from DB
        do {
            try syncMessageRepo.setSyncedOnMessageID(id: id)
            // Remove from runtime queue if successful
            self.queue = self.queue.filter {
                $0 != id
            }
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    func peek(offset: Int = 0) -> UUID? {
        if queue.count > offset {
            return queue[offset]
        } else {
            return nil
        }        
    }
    
    func element() -> UUID {
        return queue.first!
    }
    
    var count: Int {
        return self.queue.count
    }
    
    func has(id: UUID) -> Bool {
        return queue.contains(where: { filteredId in
            return filteredId == id
        })
    }
    
    private func fetchQueue() {
        if let queue = syncMessageRepo.readAllIDsNotSynced() {
            self.queue = queue
            print(self.queue)
        } else {
            print("No queue")
        }
    }
}
