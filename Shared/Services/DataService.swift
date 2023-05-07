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
    case workspaceReadFailed
}

enum DataServiceNotification: String {
    case documentUpdatedLocally
    case workspaceCreated
    case documentCreated
    case labelCreated
    case labelLinkCreated
    case blockUpdatedLocally
    case blockCreated
    case userCreated
    case blockDeleted
}

class DataService: ObservableObject {
    static let shared = DataService()
    
    var isSetup = false
    
    private var syncService: SyncService? = nil
    private var user: User? = nil
    
    var watching: Bool? {
        return syncService?.watching
    }
    
    @Published private(set) var syncStatus: SyncServiceStatus = .paused
    @Published private(set) var error: SyncServiceError? = nil
    @Published private(set) var statusCode: Int = 0
    
    func setup(user: User) {
        if !isSetup {
            self.user = user
            self.syncService = SyncService(user: user)
            self.isSetup = true
        }
    }
    
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
    
    func createBlock(user: User, workspace: Workspace, document: Document, block: Block, prev: UUID?, next: UUID?, sync: Bool = true) throws -> Block {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        do {
            // Adjust prev and next on block
            updateBlock(user: user, workspace: workspace, document: document, block: block, prev: prev, next: next)
            
            if try documentRepo.create(block: block) == false {
                throw DataServiceError.blockCreateFailed
            }

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
        
        return block
    }
    
    func createDocument(user: User, document: Document, sync: Bool = true) throws {
        let workpaceRepo = WorkspaceRepo(user: user)
        
        if workpaceRepo.create(document: document) == false {
            throw DataServiceError.documentCreateFailed
        }
        
        guard let workspace = try workpaceRepo.read(workspace: document.workspace) else {
            throw DataServiceError.workspaceReadFailed
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
    
    func createUserMessage(user: User) throws {
        guard let data = encodeUser(user: user) else {
            throw DataServiceError.userEncodeFailed
        }
        
        guard let message = packageMessage(id: user.id, type: .user, action: .create, contents: data, isApplied: true) else {
            throw DataServiceError.messagePackFailed
        }
        
        pushMessage(message, user: user)
    }
    
    func createUser(user: User, sync: Bool = true) throws {
        if UserRepo().read(id: user.id) != nil {
            print("user exists")
            return
        }
    
        if UserBuilder.create(user: user) == false {
            #if DEBUG
            fatalError()
            #endif
            throw DataServiceError.userCreateFailed
        }
        
        postNotification(.userCreated)
        
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
    
    func getLastBlock(user: User, workspace: Workspace, document: Document) -> Block? {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        return documentRepo.getLastBlock(document: document)
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
        let updatedDoc = Document(id: document.id, title: title, focused: document.focused, createdAt: document.createdAt, modifiedAt: .now, workspace: workspace.id)
        if !documentRepo.update(document: updatedDoc) {
            print("Failed to update document title: \(updatedDoc) title: \(title)")
            return
        }
        
        self.postNotification(.documentUpdatedLocally)
        
        // Sync to server
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .update, isSynced: false, isApplied: true, contents: "{\"id\": \"\(document.id.uuidString)\", \"workspace\": \"\(workspace.id.uuidString)\", \"content\": { \"title\": \"\(title)\"}}")
        syncService?.pushMessage(user: user, message: message)
    }
    
    func updateDocumentFocused(user: User, workspace: Workspace, document: Document, focused: UUID?) {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        let updatedDoc = Document(id: document.id, title: document.title, focused: focused, createdAt: document.createdAt, modifiedAt: .now, workspace: workspace.id)
        if !documentRepo.update(document: updatedDoc) {
            print("Failed to update document focused: \(updatedDoc) focused: \(document.focused)")
            return
        }
        
        self.postNotification(.documentUpdatedLocally)
        
        // Sync to server
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .update, isSynced: false, isApplied: true, contents: "{\"id\": \"\(document.id.uuidString)\", \"workspace\": \"\(workspace.id.uuidString)\", \"content\": { \"focused\": \"\(focused?.uuidString)\"}}")
        syncService?.pushMessage(user: user, message: message)
    }
    
    func updateBlock(user: User, workspace: Workspace, document: Document, block: Block, content: String? = nil, prev: UUID? = nil, next: UUID? = nil) {
        // Local updates
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        let content = content ?? block.content
        let prev = prev ?? block.prev
        let next = next ?? block.next
        
        let updatedBlock = Block(id: block.id, type: block.type, content: content, prev: prev, next: next, createdAt: block.createdAt, modifiedAt: block.modifiedAt, document: document)
        if !documentRepo.update(block: updatedBlock) {
            print("Failed to update block content: \(updatedBlock) content: \(content)")
            return
        }
        
        self.postNotification(.blockUpdatedLocally)
        
        // Sync to server
        
        do {
            let encoder = JSONEncoder()
            let localBlock = Block(id: block.id, type: block.type, content: content, prev: block.prev, next: block.next, createdAt: block.createdAt, modifiedAt: block.modifiedAt, document: block.document)
            let contentsData = try encoder.encode(localBlock)

            let contents = String(data: contentsData, encoding: .utf8)!

            let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .block, action: .update, isSynced: false, isApplied: true, contents: contents)
            syncService?.pushMessage(user: user, message: message)
        } catch let error {
            print(error)
        }
    }

    func deleteBlock(user: User, workspace: Workspace, id: UUID) {
        do {
            let repo = DocumentRepo(user: user, workspace: workspace)
            try repo.deleteBlock(id: id)
            self.postNotification(.blockDeleted)
        } catch let error {
            print(error)
        }
    }
    
    func movePromptToEmptySpace(user: User, workspace: Workspace, document: Document, emptyBlock: Block) {
        // Local updates
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        
        do {
            // Remove empty block
            try documentRepo.deleteBlock(id: emptyBlock.id)
            guard let promptBlock = try documentRepo.readPromptBlock(document: document) else {
                #if DEBUG
                fatalError()
                #endif
                return
            }
            
//            let updatedBlock = Block(id: promptBlock.id, type: promptBlock.type, content: promptBlock.content, order: order < block.order ? order : order == block.order ? order : order, createdAt: promptBlock.createdAt, modifiedAt: promptBlock.modifiedAt, document: document)
            let updatedBlock = Block(id: promptBlock.id, type: promptBlock.type, content: promptBlock.content, prev: promptBlock.prev, next: promptBlock.next, createdAt: promptBlock.createdAt, modifiedAt: promptBlock.modifiedAt, document: document)
            if !documentRepo.update(block: updatedBlock) {
                print("Failed to update block order: \(updatedBlock)")
                return
            }
            
            let now = Date.now
//            let emptySpace = Block(id: UUID(), type: .empty, content: "", order: order < block.order ? block.order : order - 1, createdAt: now, modifiedAt: now, document: document)
            let emptySpace = Block(id: UUID(), type: .body, content: "", prev: promptBlock.prev, next: promptBlock.next, createdAt: now, modifiedAt: now, document: document)
            if try !documentRepo.create(block: emptySpace) {
                print("Failed to create emptry block: \(emptySpace)")
                return
            }
            
            self.postNotification(.blockUpdatedLocally)
            
            // Sync to server
            
            let encoder = JSONEncoder()
            let localBlock = Block(id: promptBlock.id, type: promptBlock.type, content: promptBlock.content, prev: promptBlock.prev, next: promptBlock.next, createdAt: promptBlock.createdAt, modifiedAt: promptBlock.modifiedAt, document: promptBlock.document)
            let contentsData = try encoder.encode(localBlock)

            let contents = String(data: contentsData, encoding: .utf8)!

            let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .block, action: .update, isSynced: false, isApplied: true, contents: contents)
            syncService?.pushMessage(user: user, message: message)
            
        } catch let error {
            print(error)
        }
    }
    
    func startWatching(user: User) {
        
        _ = syncService?.$syncStatus.sink { value in
            self.syncStatus = value
        }
        
        _ = syncService?.$statusCode.sink { value in
            self.statusCode = value
        }
        
        _ = syncService?.$error.sink { value in
            self.error = value
        }
        
        syncService?.startQueue()
    }
    
    func stopWatching() {
        syncService?.stopQueue()
    }

    func fetchMessageIDs(user: User) {
        syncService?.fetchMessageIDs(user: user)
    }
    
    private func postNotification(_ notification: DataServiceNotification) {
        NotificationCenter.default.post(name: Notification.Name(notification.rawValue), object: nil)
    }
    
    private func packageMessage(id: String, type: SyncMessageType, action: SyncMessageAction, contents: Data, isApplied: Bool = false) -> SyncMessage? {
        guard let contents = String(data: contents, encoding: .utf8) else {
            #if DEBUG
            fatalError()
            #endif
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
        syncService?.pushMessage(user: user, message: message)
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
