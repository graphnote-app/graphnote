//
//  DataService.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/13/23.
//

import Foundation

enum DataServiceError: Error {
    case messagePackFailed
    case documentEncodeFailed
    case documentCreateFailed
    case workspaceCreateFailed
    case workspaceEncodeFailed
    case userCreateFailed
    case userEncodeFailed
    case labelCreateFailed
    case labelEncodeFailed
    case labelLinkEncodeFailed
    case attachmentExists
    case blockEncodeFailed
    case blockCreateFailed
    case blockFetchFailed
    case blockUpdateFailed
}

enum DataServiceNotification: String {
    case documentUpdatedLocally
    case workspaceCreated
    case documentCreated
    case labelCreated
    case labelLinkCreated
    case blockUpdatedLocally
    case blockCreated
}

class DataService: ObservableObject {
    static let shared = DataService()
    
    private let syncService = SyncService()
    
    var watching: Bool {
        return syncService.watching
    }
    
    @Published private(set) var syncStatus: SyncServiceStatus = .paused
    @Published private(set) var error: SyncServiceError? = nil
    @Published private(set) var statusCode: Int = 201
    
    func attachLabel(user: User, label: Label, document: Document, workspace: Workspace, sync: Bool = true) throws {
        let workspaceRepo = WorkspaceRepo(user: user)
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        if (try documentRepo.attachExists(label: label, document: document)) == false {
//                if let link = documentRepo.attach(label: label, document: document) {
                let link = LabelLink(id: UUID(), label: label.id, document: document.id, workspace: workspace.id, createdAt: .now, modifiedAt: .now)
                postNotification(.labelLinkCreated)
                
                guard let data = encodeLabelLink(link: link) else {
                    throw DataServiceError.labelLinkEncodeFailed
                }
                
                guard let message = packageMessage(id: user.id, type: .labelLink, action: .create, contents: data, isApplied: false) else {
                    throw DataServiceError.messagePackFailed
                }
                
                
                if sync {
                    pushMessage(message, user: user)
                }
//                } else {
//                    throw DataServiceError.attachmentExists
//                }
        } else {
            throw DataServiceError.attachmentExists
        }
    }
    
    func createLabel(user: User, label: Label, workspace: Workspace, sync: Bool = true) throws {
        let workspaceRepo = WorkspaceRepo(user: user)
        
        let labelRepo = LabelRepo(user: user, workspace: workspace)
        
        if try labelRepo.exists(label: label) == nil {
            if try labelRepo.create(label: label) == nil {
                throw DataServiceError.labelCreateFailed
            }
            
            postNotification(.labelCreated)
            
            if sync {
                guard let data = encodeLabel(label: label) else {
                    throw DataServiceError.labelEncodeFailed
                }
                
                guard let message = packageMessage(id: user.id, type: .label, action: .create, contents: data, isApplied: true) else {
                    throw DataServiceError.messagePackFailed
                }
                
                pushMessage(message, user: user)
            }
        }
    }
    
    func createBlock(user: User, workspace: Workspace, document: Document, block: Block, sync: Bool = true) throws {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        do {
            // Push all blocks order past index by one
            guard let blocksAfter = try documentRepo.readAllWhere(document: document, orderEqualsOrGreaterThan: block.order) else {
                throw DataServiceError.blockFetchFailed
            }
            
            for after in blocksAfter.sorted(by: { blockA, blockB in
                blockA.order > blockB.order
            }) {
                let block = Block(id: after.id, type: after.type, content: after.content, order: after.order + 1, createdAt: after.createdAt, modifiedAt: .now, document: after.document)
                print(block.order)
                if !documentRepo.update(block: block) {
                    throw DataServiceError.blockUpdateFailed
                }
            }
            
            if try documentRepo.create(block: block) == false {
                throw DataServiceError.blockCreateFailed
            }
            
            // - TODO: Should I sync now?

        } catch let error {
            print(error)
            throw error
        }
        
        postNotification(.blockCreated)
        
        if sync {
            guard let data = encodeBlock(block: block) else {
                throw DataServiceError.blockEncodeFailed
            }
            
            guard let message = packageMessage(id: user.id, type: .block, action: .create, contents: data, isApplied: true) else {
                throw DataServiceError.messagePackFailed
            }
            
            pushMessage(message, user: user)

        }
    }
    
    func createDocument(user: User, document: Document, sync: Bool = true) throws {
        let workpaceRepo = WorkspaceRepo(user: user)
        
        if workpaceRepo.create(document: document) == false {
            throw DataServiceError.documentCreateFailed
        }
        
        postNotification(.documentCreated)
        
        if sync {
            guard let data = encodeDocument(document: document) else {
                throw DataServiceError.documentEncodeFailed
            }
            
            guard let message = packageMessage(id: user.id, type: .document, action: .create, contents: data, isApplied: true) else {
                throw DataServiceError.messagePackFailed
            }
            
            pushMessage(message, user: user)

        }
    }
    
    func createWorkspace(user: User, workspace: Workspace, sync: Bool = true) throws {
        let workpaceRepo = WorkspaceRepo(user: user)
        
        if workpaceRepo.create(workspace: workspace) == false {
            throw DataServiceError.workspaceCreateFailed
        }
        
        postNotification(.workspaceCreated)
        
        if sync {
            guard let data = encodeWorkspace(workspace: workspace) else {
                throw DataServiceError.workspaceEncodeFailed
            }
            
            guard let message = packageMessage(id: user.id, type: .workspace, action: .create, contents: data, isApplied: true) else {
                throw DataServiceError.messagePackFailed
            }
            
            pushMessage(message, user: user)
        }
    }
    
    func createUser(user: User, sync: Bool = true) throws {
        if UserBuilder.create(user: user) == false {
            throw DataServiceError.userCreateFailed
        }
        
        if sync {
            guard let data = encodeUser(user: user) else {
                throw DataServiceError.userEncodeFailed
            }
            
            guard let message = packageMessage(id: user.id, type: .user, action: .create, contents: data, isApplied: true) else {
                throw DataServiceError.messagePackFailed
            }
            
            pushMessage(message, user: user)
                
        }
    }
    
    func getLastIndex(user: User, workspace: Workspace, document: Document) -> Int? {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        return documentRepo.getLastIndex(document: document)
    }
    
    func getUser(id: String) -> User? {
        let userRepo = UserRepo()
        return userRepo.read(id: id)
    }
    
    func readBlock(user: User, workspace: Workspace, document: Document, block: UUID) -> Block? {
        do {
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            return try documentRepo.readBlock(document: document, block: block)
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
            return nil
        }
    }
    
    func readBlocks(user: User, workspace: Workspace, document: Document) -> [Block]? {
        do {
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            return try documentRepo.readBlocks(document: document)
        } catch let error {
            print(error)
            #if DEBUG
            fatalError()
            #endif
            return nil
        }
    }
    
    func updateDocumentTitle(user: User, workspace: Workspace, document: Document, title: String) {
        // Local updates
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        let updatedDoc = Document(id: document.id, title: title, createdAt: document.createdAt, modifiedAt: .now, workspace: workspace.id)
        if !documentRepo.update(document: updatedDoc) {
            print("Failed to update document title: \(updatedDoc) title: \(title)")
            return
        }
        
        self.postNotification(.documentUpdatedLocally)
        
        // Sync to server
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .update, isSynced: false, isApplied: true, contents: "{\"id\": \"\(document.id.uuidString)\", \"workspace\": \"\(workspace.id.uuidString)\", \"content\": { \"title\": \"\(title)\"}}")
        syncService.pushMessage(user: user, message: message)
    }
    
    func updateBlock(user: User, workspace: Workspace, document: Document, block: Block, content: String) {
        // Local updates
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        let updatedBlock = Block(id: block.id, type: block.type, content: content, order: block.order, createdAt: block.createdAt, modifiedAt: block.modifiedAt, document: document)
        if !documentRepo.update(block: updatedBlock) {
            print("Failed to update block content: \(updatedBlock) content: \(content)")
            return
        }
        
        self.postNotification(.blockUpdatedLocally)
        
        // Sync to server
        
        do {
            let encoder = JSONEncoder()
            let localBlock = Block(id: block.id, type: block.type, content: content, order: block.order, createdAt: block.createdAt, modifiedAt: block.modifiedAt, document: block.document)
            let contentsData = try encoder.encode(localBlock)

            let contents = String(data: contentsData, encoding: .utf8)!

            let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .block, action: .update, isSynced: false, isApplied: true, contents: contents)
            syncService.pushMessage(user: user, message: message)
        } catch let error {
            print(error)
        }
    }
    
    func startWatching(user: User) {
        _ = syncService.$syncStatus.sink { value in
            self.syncStatus = value
        }
        
        _ = syncService.$statusCode.sink { value in
            self.statusCode = value
        }
        
        _ = syncService.$error.sink { value in
            self.error = value
        }
        
        syncService.startQueue(user: user)
    }
    
    func stopWatching() {
        syncService.stopQueue()
    }

    func fetchMessageIDs(user: User) {
        syncService.fetchMessageIDs(user: user)
    }
    
    private func postNotification(_ notification: DataServiceNotification) {
        NotificationCenter.default.post(name: Notification.Name(notification.rawValue), object: nil)
    }
    
    private func packageMessage(id: String, type: SyncMessageType, action: SyncMessageAction, contents: Data, isApplied: Bool = false) -> SyncMessage? {
        guard let contents = String(data: contents, encoding: .utf8) else {
            return nil
        }
        
        return SyncMessage(
            id: UUID(),
            user: id,
            timestamp: .now,
            type: type,
            action: action,
            isSynced: false,
            isApplied: isApplied,
            contents: contents
        )
    }
    
    private func pushMessage(_ message: SyncMessage, user: User) {
        syncService.pushMessage(user: user, message: message)
    }
    
    private func saveMessage(_ message: SyncMessage, user: User) -> Bool {
//        return syncService.createMessage(user: user, message: message)
        return false
    }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
    
    
    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }
    
    private func encodeLabelLink(link: LabelLink) -> Data? {
        do {
            return try encoder.encode(link)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func encodeLabel(label: Label) -> Data? {
        do {
            return try encoder.encode(label)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func encodeBlock(block: Block) -> Data? {
        do {
            return try encoder.encode(block)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func encodeDocument(document: Document) -> Data? {
        do {
            return try encoder.encode(document)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func encodeWorkspace(workspace: Workspace) -> Data? {
        do {
            return try encoder.encode(workspace)
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func encodeUser(user: User) -> Data? {
        do {
            return try encoder.encode(user)
        } catch let error {
            print(error)
            return nil
        }
    }
}
