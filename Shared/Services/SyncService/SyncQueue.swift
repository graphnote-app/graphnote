//
//  SyncQueue.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/7/23.
//

import Foundation

class SyncQueue {
    let user: User
    
    private var queue = [SyncMessage]()
    
    private lazy var syncMessageRepo = {
        return SyncMessageRepo(user: user)
    }()
    
    init(user: User) {
        self.user = user
        self.queue = []
        
        // Read from the database to the queue
        fetchQueue()
    }
    
    func add(message: SyncMessage) -> Bool {
        // Add to DB
        do {
            try syncMessageRepo.create(message: message)
            // Add to runtime queue if successful
            self.queue.append(message)
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    func remove(id: UUID) -> Bool {
        // remove from DB
        do {
            try syncMessageRepo.updateToIsSynced(id: id)
            // Remove from runtime queue if successful
            self.queue = self.queue.filter {
                $0.id != id
            }
            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    func peek() -> SyncMessage? {
        return queue.first
    }
    
    func element() -> SyncMessage {
        return queue.first!
    }
    
    var count: Int {
        return self.queue.count
    }
    
    private func fetchQueue() {
        if let queue = try? syncMessageRepo.readAll() {
            self.queue = queue
        }
    }
}
