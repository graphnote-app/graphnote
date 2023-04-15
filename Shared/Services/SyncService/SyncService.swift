//
//  SyncService.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/4/23.
//

import Foundation

enum SyncServiceError: Error {
    case postFailed
    case decoderFailed
    case userNotFound
    case systemNetworkRestrained
    case lowDataMode
    case cellular
    case cannotConnectToHost
    case createMessageFailed
    case getFailed
    case unknown
}

enum SyncServiceNotification: String {
    case networkSyncFailed
    case networkSyncSuccess
    case messageIDsFetched
    case workspaceCreated
    case documentCreated
    case documentUpdateSynced
    case documentUpdateReceived
    case labelCreated
    case labelLinkCreated
}

enum SyncServiceStatus {
    case paused
    case failed
    case success
}

let baseURL = URL(string: "http://10.0.0.207:3000/")!

class SyncService: ObservableObject {    
    
    enum HTTPMethod: String {
        case post
        case get
    }
    
    let syncInterval = 1.0
    let fetchInterval = 4.0
    @Published private(set) var statusCode: Int = 201
    @Published private(set) var error: SyncServiceError? = nil {
        didSet {
            if oldValue != error {
                if error == nil {
                    syncStatus = .success
                } else {
                    syncStatus = .failed
                }
            }
        }
    }
    
    @Published private(set) var syncStatus: SyncServiceStatus = .success
    @Published private(set) var watching = false
    
    private var timer: Timer? = nil
    private var fetchTimer: Timer? = nil
    private var requestIDs: Set<UUID> = Set()
    private var processingPullQueue: [UUID : Bool] = [:]
    
    private var pushQueue: DBQueue? = nil
    private var pullQueue: [UUID] = []
    
    private func getLastSyncTime(user: User) -> Date? {
        let syncMessageRepo = SyncMessageRepo(user: user)
        return try? syncMessageRepo.readLastSyncTime()
    }
    
    func startQueue(user: User) {
        if pushQueue == nil {
            self.pushQueue = DBQueue(user: user)
        }
        
        // Invalidate timer always so we don't get runaway timers
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { timer in
            self.processQueues(user: user)
        }
        
        self.fetchTimer?.invalidate()
        self.fetchTimer = nil
        self.fetchTimer = Timer.scheduledTimer(withTimeInterval: fetchInterval, repeats: true) { timer in
            self.fetchMessageIDs(user: user)
        }

        watching = true
    }
    
    private func processQueues(user: User) {
        self.processPushQueue(user: user)
        if self.processingPullQueue.values.allSatisfy({
            $0 == false
        }) {
            self.processPullQueue(user: user)
        }
        processMessageIDs(user: user)
    }
    
    func stopQueue() {
        watching = false
        self.timer?.invalidate()
        self.fetchTimer?.invalidate()
        self.timer = nil
        self.fetchTimer = nil
    }
    
    private func postSyncNotification(_ notification: SyncServiceNotification) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(notification.rawValue), object: nil)
        }
    }
    
    func processPullQueue(user: User) {
        for queueUUID in self.pullQueue {
            var request = URLRequest(url: baseURL.appendingPathComponent("message").appending(queryItems: [.init(name: "id", value: queueUUID.uuidString)]))
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error as? URLError {
                        switch error.networkUnavailableReason {
                        case .cellular:
                            self.error = .cellular
                            return
                        case .constrained:
                            self.error = .lowDataMode
                            return
                        case .expensive:
                            self.error = .systemNetworkRestrained
                            return
                        case .none:
                            self.error = .unknown
                            break
                        case .some(_):
                            self.error = .unknown
                            break
                        }
                        
                        print(error.errorCode)
                        self.processingPullQueue[queueUUID] = false
                        if error.errorCode == URLError.cannotConnectToHost.rawValue {
                            self.error = .cannotConnectToHost
                            return
                        }
                        
                        self.error = .postFailed
                        return
                    }
                    
                    if let _ = response as? HTTPURLResponse {
                        self.error = nil
                    }
                    
                    if let data {
                        let decoder = JSONDecoder()
                        let formatter = DateFormatter()
                        formatter.calendar = Calendar(identifier: .iso8601)
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        decoder.dateDecodingStrategy = .millisecondsSince1970
                        
                        do {
                            let syncMessage = try decoder.decode(SyncMessage.self, from: data)
                            let repo = SyncMessageRepo(user: user)
                            
                            if !repo.has(id: syncMessage.id) {
                                try repo.create(message: syncMessage)
                            }
                            self.pullQueue.remove(at: 0)
                            self.processingPullQueue[queueUUID] = false
                            
                        } catch let error {
                            print(error)
                            self.error = .unknown
                            self.processingPullQueue[queueUUID] = false
                        }
                    }
                }
            }
            
            task.resume()
            self.processingPullQueue[queueUUID] = true
        }
        
    }
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
    
    func processMessageIDs(user: User) {
        // Pull messages
        
        let syncMessageRepo = SyncMessageRepo(user: user)
        guard let ids = syncMessageRepo.readAllIDs(includeSynced: false) else {
            print("NO IDs")
            return
        }
        
        // TODO: Batch pulls
        for id in ids {
            if !syncMessageRepo.has(id: id) {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                var request = URLRequest(url: baseURL.appendingPathComponent("message").appending(queryItems: [.init(name: "id", value: id.uuidString)]))
                request.httpMethod = "GET"
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                        if let error = error as? URLError {
                            switch error.networkUnavailableReason {
                            case .cellular:
                                self.error = .cellular
                                return
                            case .constrained:
                                self.error = .lowDataMode
                                return
                            case .expensive:
                                self.error = .systemNetworkRestrained
                                return
                            case .none:
                                self.error = .unknown
                                break
                            case .some(_):
                                self.error = .unknown
                                break
                            }
                            
                            print(error.errorCode)
                            
                            if error.errorCode == URLError.cannotConnectToHost.rawValue {
                                self.error = .cannotConnectToHost
                                return
                            }
                            
                            self.error = .postFailed
                            return
                        }
                        
                        if let response = response as? HTTPURLResponse {
                            self.error = nil
                        }
                        
                        if let data {
                            do {
                                let syncMessage = try self.decoder.decode(SyncMessage.self, from: data)
                                if let contentsData = syncMessage.contents.data(using: .utf8) {
                                    switch syncMessage.type {
                                    case .user:
                                        self.syncMessageUser(user: user, message: syncMessage, data: contentsData)
                                    case .document:
                                        self.syncMessageDocument(user: user, message: syncMessage, data: contentsData)
                                    case .workspace:
                                        self.syncMessageWorkspace(user: user, message: syncMessage, data: contentsData)
                                    case .label:
                                        self.syncMessageLabel(user: user, message: syncMessage, data: contentsData)
                                    case .labelLink:
                                        self.syncMessageLabelLink(user: user, message: syncMessage, data: contentsData)
                                    }
                                }
                            } catch let error {
                                print(error)
                            }
                        }
                    }
                }
                
                task.resume()
            }
        }
    }
    
    private func syncMessageUser(user: User, message: SyncMessage, data: Data) {
        
    }
    
    private func syncMessageLabelLink(user: User, message: SyncMessage, data: Data) {
        switch message.action {
        case .create:
            let labelLink = try! decoder.decode(LabelLink.self, from: data)
            self.processLabelLink(labelLink, user: user)
        case .update:
            break
        case .delete:
            break
        case .read:
            break
        }
    }
    
    private func syncMessageLabel(user: User, message: SyncMessage, data: Data) {
        switch message.action {
        case .create:
            let label = try! decoder.decode(Label.self, from: data)
            self.processLabel(label, user: user)
        case .update:
            break
        case .delete:
            break
        case .read:
            break
        }
    }
    
    private func syncMessageDocument(user: User, message: SyncMessage, data: Data) {
        switch message.action {
        case .create:
            let document = try! decoder.decode(Document.self, from: data)
            self.processDocument(document, user: user)
        case .update:
            let documentUpdate = try! decoder.decode(DocumentUpdate.self, from: data)
            updateDocument(documentUpdate, message: message, user: user)
            self.postSyncNotification(.documentUpdateReceived)
        case .delete:
            break
        case .read:
            break
        }
    }
    
    private func syncMessageWorkspace(user: User, message: SyncMessage, data: Data) {
        switch message.action {
        case .create:
            let workspace = try! decoder.decode(Workspace.self, from: data)
            self.processWorkspace(workspace, user: user)
        case .update:
            break
        case .delete:
            break
        case .read:
            break
        }
    }
    
    private func updateDocument(_ documentUpdate: DocumentUpdate, message: SyncMessage, user: User) {
        
        let workspaceRepo = WorkspaceRepo(user: user)
        if let workspace = try? workspaceRepo.read(workspace: documentUpdate.workspace) {
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            guard let document = try? documentRepo.read(id: documentUpdate.id) else {
                print("document couldn't be read: \(documentUpdate.id)")
                return
            }
            
            if document.modifiedAt < message.timestamp {
                for diff in documentUpdate.content.keys {
                    switch diff {
                    case "title":
                        if let title = documentUpdate.content["title"] {
                            let updatedDocument = Document(
                                id: document.id,
                                title: title,
                                createdAt: document.createdAt,
                                modifiedAt: message.timestamp,
                                workspace: document.workspace
                            )
                            
                            if documentRepo.update(document: updatedDocument) {
                                self.postSyncNotification(.documentUpdateSynced)
                            } else {
                                print("Document update failed")
                            }
                            
                        }
                        
                    default:
                        fatalError("diff key isn't a switch case: \(diff)")
                        break
                    }
                }
            } else {
                print("Dropping document")
            }
        }
    }
    
    private func processLabelLink(_ labelLink: LabelLink, user: User) {
        do {
            let workspaceRepo = WorkspaceRepo(user: user)
            guard let workspace = try? workspaceRepo.read(workspace: labelLink.workspace) else {
                print("Couldn't read workspace: \(labelLink.workspace)")
                return
            }
            
            let labelRepo = LabelRepo(user: user, workspace: workspace)
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            print(labelLink)
            if let document = try documentRepo.read(id: labelLink.document),
               let label = try labelRepo.read(id: labelLink.label) {
                if documentRepo.attach(label: label, document: document) != nil {
                    self.postSyncNotification(.labelLinkCreated)
                } else {
                    print("LabelLink creation failed")
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    private func processLabel(_ label: Label, user: User) {
        let workspaceRepo = WorkspaceRepo(user: user)
        if workspaceRepo.create(label: label) {
            self.postSyncNotification(.labelCreated)
        } else {
            print("Label creation failed")
        }
    }
    
    private func processDocument(_ doc: Document, user: User) {
        let workspaceRepo = WorkspaceRepo(user: user)
        if workspaceRepo.create(document: doc) {
            self.postSyncNotification(.documentCreated)
        } else {
            print("Document creation failed")
        }
    }
    
    private func processWorkspace(_ workspace: Workspace, user: User) {
        let userRepo = UserRepo()
        if userRepo.create(workspace: workspace, for: user) {
            self.postSyncNotification(.workspaceCreated)
        } else {
            print("Workspace creation failed")
        }
    }
    
    private func processPushQueue(user: User) {
        // Push messages
        if let queueItem = self.pushQueue?.peek() {
            if queueItem.isSynced == true {
                self.pushQueue?.remove(id: queueItem.id)
                return
            }
            
            if !self.requestIDs.contains(queueItem.id) {
                self.requestIDs.insert(queueItem.id)
                self.request(message: queueItem) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            print(response.statusCode)
                            switch response.statusCode {
                                
                            case 201, 409:
                                // Drop the item from the queue
                                if self.pushQueue?.remove(id: queueItem.id) == true {
                                    self.syncStatus = .success
                                    print(queueItem)
                                    self.postSyncNotification(.networkSyncSuccess)
                                }
                                break
                            case 500:
                                print("Server error: \(response.statusCode)")
                                self.postSyncNotification(.networkSyncFailed)
                                self.syncStatus = .failed
                                break
                            default:
                                print("generic request method in processQueue returned statusCode: \(response.statusCode)")
                                self.postSyncNotification(.networkSyncFailed)
                                self.syncStatus = .failed
                                break
                            }
                            
                            self.statusCode = response.statusCode
                            self.error = nil
                            
                            break
                        case .failure(let error):
                            print(error)
                            self.stopQueue()
                            self.error = error
                            self.postSyncNotification(.networkSyncFailed)
                            self.syncStatus = .failed
                            break
                        }
                        
                        self.requestIDs.remove(queueItem.id)
                    }
                }
            }
        }
    }
    
    func createMessage(user: User, message: SyncMessage) {
        self.pushQueue?.add(message: message)
    }
    
    func createWorkspace(user: User, workspace: Workspace) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let contents = try! encoder.encode(workspace)
        print("contents: \(contents)")
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .workspace, action: .create, isSynced: false, contents: String(data: contents, encoding: .utf8)!)
        
        // Save message to local queue
        print(self.pushQueue?.add(message: message))
        processWorkspace(workspace, user: user)
    }
    
    func request(message: SyncMessage, callback: @escaping (_ result: Result<HTTPURLResponse, SyncServiceError>) -> Void) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        var request = URLRequest(url: baseURL.appendingPathComponent("message"))
        request.httpMethod = "POST"
        request.httpBody = try! encoder.encode(message)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error as? URLError {
                switch error.networkUnavailableReason {
                case .cellular:
                    callback(.failure(.cellular))
                    return
                case .constrained:
                    callback(.failure(.lowDataMode))
                    return
                case .expensive:
                    callback(.failure(.systemNetworkRestrained))
                    return
                case .none:
                    break
                case .some(_):
                    break
                }
                
                print(error.errorCode)
                
                if error.errorCode == URLError.cannotConnectToHost.rawValue {
                    callback(.failure(.cannotConnectToHost))
                    return
                }
                
                callback(.failure(.postFailed))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                callback(.success(response))
                return
            }
            
//            if let data {
//                print(data)
//            }
        }
        
        task.resume()
    }
    
    func createUser(user: User) {
        // Create message
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let contents = try! encoder.encode(user)
        
//        let json = try! JSONSerialization.jsonObject(with: contents) as! Dictionary<String, Any>
//        print(json)
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .user, action: .create, isSynced: false, contents: String(data: contents, encoding: .utf8)!)
        let repo = SyncMessageRepo(user: user)
        try? repo.create(message: message)
        // Save message to local queue
        print(self.pushQueue?.add(message: message))
//        processEntity(data: contents, user: user)
        
    }
    
    func createDocument(user: User, document: Document) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let contents = try! encoder.encode(document)

        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .create, isSynced: false, contents: String(data: contents, encoding: .utf8)!)
        let repo = SyncMessageRepo(user: user)
        try? repo.create(message: message)
        // Save message to local queue
        print(self.pushQueue?.add(message: message))
        processDocument(document, user: user)
//        let workspaceRepo = WorkspaceRepo(user: user)
//        try? workspaceRepo.create(document: document, for: user)
        
    }
    
    func fetchMessageIDs(user: User) {
        let syncMessageRepo = SyncMessageRepo(user: user)
        
        if let lastSyncTime = getLastSyncTime(user: user) {
            print(lastSyncTime.timeIntervalSince1970)
            
            var request = URLRequest(url: baseURL.appendingPathComponent("message/ids")
                .appending(queryItems: [.init(name: "user", value: user.id), .init(name: "last", value: String(lastSyncTime.timeIntervalSince1970))]))
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error as? URLError {
                        if error.errorCode == URLError.cannotConnectToHost.rawValue {
                            self.error = .cannotConnectToHost
                            self.postSyncNotification(.networkSyncFailed)
                            return
                        }
                        
                        switch error.networkUnavailableReason {
                        case .cellular:
                            self.error = .cellular
                        case .constrained:
                            self.error = .lowDataMode
                        case .expensive:
                            self.error = .systemNetworkRestrained
                        case .none:
                            self.error = .unknown
                        case .some(_):
                            self.error = .unknown
                        }
                        
                        print(error.errorCode)
                        
                        self.postSyncNotification(.networkSyncFailed)
                        return
                    }
                    
                    if let response = response as? HTTPURLResponse {
                        print(response)
                        
                        switch response.statusCode {
                        case 200:
                            break
                        default:
                            print(response.statusCode)
                            self.error = .getFailed
                            self.postSyncNotification(.networkSyncFailed)
                            return
                        }
                        
                    }
                    
                    if let data {

                        let decoder = JSONDecoder()
                        
                        let syncMessageIDsResult = try! decoder.decode(SyncMessageIDsResult.self, from: data)
                        let lastSyncTime = syncMessageIDsResult.lastSyncTime
                        print("lastSyncTime from server: \(lastSyncTime)")
                        let lastSyncDate = Date(timeIntervalSince1970: lastSyncTime)
                        let ids = syncMessageIDsResult.ids
                        
    //                    print(ids)
                        
                        // Save ids then set sync time if successful
                        do {
                            for id in ids {
                                let uuid = UUID(uuidString: id)!
                                try syncMessageRepo.create(id: uuid)
                                self.pullQueue.append(uuid)
                            }
                            
                            try syncMessageRepo.setLastSyncTime(time: lastSyncDate)
                            
                            DispatchQueue.main.async {
                                self.postSyncNotification(.messageIDsFetched)
                            }
                            
                        } catch let error {
                            print(error)
                            self.error = .createMessageFailed
                            self.postSyncNotification(.networkSyncFailed)
                            return
                        }
                        
                    }
                    
                    self.error = nil
                    self.postSyncNotification(.networkSyncSuccess)
                }
                
            }
            
            task.resume()
        } else {
            try? DispatchQueue.global(priority: .default).sync {
                try? syncMessageRepo.setLastSyncTime(time: nil)
            }
        }
    }
}
