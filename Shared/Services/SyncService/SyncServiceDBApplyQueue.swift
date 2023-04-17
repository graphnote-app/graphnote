//
//  SyncServiceDBApplyQueue.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/7/23.
//

import Foundation

class SyncServiceDBApplyQueue {
    let user: User
    
    var queue = [SyncMessage]()
    
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
        do {
//            try syncMessageRepo.create(id: message.id)
            // Add to runtime queue
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
            try syncMessageRepo.updateToIsApplied(id: id)
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
    
    func peek(offset: Int = 0) -> SyncMessage? {
        if count > offset {
            return self.queue[offset]
        } else {
            return nil
        }
    }
    
    func element() -> SyncMessage {
        return queue.first!
    }
    
    var count: Int {
        return self.queue.count
    }
    
    func has(message: SyncMessage) -> Bool {
        return queue.contains(where: { filterMessage in
            return filterMessage.id == message.id
        })
    }
    
    func fetchQueue() {
        if let queue = try? syncMessageRepo.readAllWhere(isApplied: false) {
            self.queue = queue
//            print(self.queue)
        }
    }
}
