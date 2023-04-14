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
}

enum DataServiceNotification: String {
    case documentUpdatedLocally
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
    
    func createDocument(user: User, document: Document, sync: Bool = true) throws {
        let workpaceRepo = WorkspaceRepo(user: user)
        
        if workpaceRepo.create(document: document) == false {
            throw DataServiceError.documentCreateFailed
        }
        
        if sync {
            guard let data = encodeDocument(document: document) else {
                throw DataServiceError.documentEncodeFailed
            }
            
            guard let message = packageMessage(id: user.id, type: .document, action: .create, contents: data) else {
                throw DataServiceError.messagePackFailed
            }
            
            saveMessage(message, user: user)

        }
    }
    
    func createWorkspace(user: User, workspace: Workspace, sync: Bool = true) throws {
        let workpaceRepo = WorkspaceRepo(user: user)
        
        if workpaceRepo.create(workspace: workspace) == false {
            throw DataServiceError.workspaceCreateFailed
        }
        
        if sync {
            guard let data = encodeWorkspace(workspace: workspace) else {
                throw DataServiceError.workspaceEncodeFailed
            }
            
            guard let message = packageMessage(id: user.id, type: .workspace, action: .create, contents: data) else {
                throw DataServiceError.messagePackFailed
            }
            
            saveMessage(message, user: user)

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
            
            guard let message = packageMessage(id: user.id, type: .user, action: .create, contents: data) else {
                throw DataServiceError.messagePackFailed
            }
            
            saveMessage(message, user: user)
                
        }
    }
    
    func getUser(id: String) -> User? {
        let userRepo = UserRepo()
        return userRepo.read(id: id)
    }
    
    func fetchUser(id: String, callback: @escaping (_ user: User?, _ error: SyncServiceError?) -> Void) {
        var request = URLRequest(url: syncService.baseURL.appendingPathComponent("user")
            .appending(queryItems: [.init(name: "id", value: id)]))
        request.httpMethod = "GET"
        print("SyncService fetchUser fetching: \(id)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
                callback(nil, SyncServiceError.getFailed)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
                print(response)
                switch response.statusCode {
                case 200:
                    if let data {
                        
                        do {
                            let user = try self.decoder.decode(User.self, from: data)
                            callback(user, nil)
                        } catch let error {
                            print(error)
                            callback(nil, SyncServiceError.decoderFailed)
                        }
                        
                    }
                case 404:
                    callback(nil, SyncServiceError.userNotFound)
                default:
                    print("Response failed with statusCode: \(response.statusCode)")
                    callback(nil, SyncServiceError.unknown)
                }
                
            }
        }
        
        task.resume()
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
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .update, isSynced: false, contents: "{\"id\": \"\(document.id.uuidString)\", \"workspace\": \"\(workspace.id.uuidString)\", \"content\": { \"title\": \"\(title)\"}}")
        syncService.createMessage(user: user, message: message)
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
    
    func processMessageIDs(user: User) {
        syncService.processMessageIDs(user: user)
    }
    
    func fetchMessageIDs(user: User) {
        syncService.fetchMessageIDs(user: user)
    }
    
    private func postNotification(_ notification: DataServiceNotification) {
        NotificationCenter.default.post(name: Notification.Name(notification.rawValue), object: nil)
    }
    
    private func packageMessage(id: String, type: SyncMessageType, action: SyncMessageAction, contents: Data) -> SyncMessage? {
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
            contents: contents
        )
    }
    
    private func saveMessage(_ message: SyncMessage, user: User) {
        syncService.createMessage(user: user, message: message)
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
