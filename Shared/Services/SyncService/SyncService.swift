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
    case blockUpdated
    case blockCreated
    case userSyncCreated
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
    
    let syncInterval = 0.125
    let fetchInterval = 2.0
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
    
    private let user: User
    private var timer: Timer? = nil
    private var fetchTimer: Timer? = nil
    private var requestIDs: Set<UUID> = Set()
    private var processingPullQueue: [UUID : Bool] = [:]
    private var processingApplyQueue: [UUID : Bool] = [:]
    private var processingPushQueue = false
    
    private var pushQueue: SyncServiceDBPushQueue? = nil
    private var pullQueue: SyncServiceDBPullQueue? = nil
    private var applyQueue: SyncServiceDBApplyQueue? = nil
    
    private func getLastSyncTime(user: User) -> Date? {
        let syncMessageRepo = SyncMessageRepo(user: user)
        return try? syncMessageRepo.readLastSyncTime()
    }
    
    init(user: User) {
        self.user = user
        if pushQueue == nil {
            self.pushQueue = SyncServiceDBPushQueue(user: user)
        }
        
        if pullQueue == nil {
            self.pullQueue = SyncServiceDBPullQueue(user: user)
        }
        
        if applyQueue == nil {
            self.applyQueue = SyncServiceDBApplyQueue(user: user)
        }
    }
    
    func startQueue() {
        // Invalidate timer always so we don't get runaway timers
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { timer in
//            DispatchQueue.global(qos: .userInitiated).async {
                self.processQueues(user: self.user)
//            }
        }
        
        self.fetchTimer?.invalidate()
        self.fetchTimer = nil
        self.fetchTimer = Timer.scheduledTimer(withTimeInterval: fetchInterval, repeats: true) { timer in
            self.fetchMessageIDs(user: self.user)
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
        
        self.processApplyQueue(user: user)
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
    
    func processApplyQueue(user: User) {
        var i = 0
        
        guard let applyQueue else {
            #if DEBUG
            fatalError()
            #endif
            return
        }
        
        applyQueue.fetchQueue()
        
        var count = applyQueue.count
        
        while count > 0 && i < count {
            applyQueue.fetchQueue()
            count = applyQueue.count
                        
            if let queueItem = self.applyQueue?.peek(offset: i) {
                if processingApplyQueue[queueItem.id] == true {
                    return
                }
                
                processingApplyQueue[queueItem.id] = true
                if queueItem.isApplied == true {
                    #if DEBUG
                    fatalError()
                    #endif
                    return
                }
                
                var success = false
                if let contentsData = queueItem.contents.data(using: .utf8) {
                    switch queueItem.type {
                    case .user:
                        success = self.syncMessageUser(user: user, message: queueItem, data: contentsData)
                    case .document:
                        success = self.syncMessageDocument(user: user, message: queueItem, data: contentsData)
                    case .workspace:
                        success = self.syncMessageWorkspace(user: user, message: queueItem, data: contentsData)
                    case .label:
                        success = self.syncMessageLabel(user: user, message: queueItem, data: contentsData)
                    case .labelLink:
                        success = self.syncMessageLabelLink(user: user, message: queueItem, data: contentsData)
                    case .block:
                        success = self.syncMessageBlock(user: user, message: queueItem, data: contentsData)
                    }
                }
                
                if success {
                    let repo = SyncMessageRepo(user: user)
                    if !repo.has(id: queueItem.id) {
                        try! repo.create(id: queueItem.id, isApplied: true)
                    }
                    
                    if applyQueue.remove(id: queueItem.id) {
                        processingApplyQueue[queueItem.id] = false
                    }

                } else {
                    
                    if i == count - 1 {
                        i = 0
                    } else {
                        i += 1
                    }
                    
                    processingApplyQueue[queueItem.id] = false
                }
            }
        }
    }
    
    func processPullQueue(user: User) {
        for i in 0..<10 {
            self.pullQueue?.fetchQueue()
            if let queueUUID = self.pullQueue?.peek(offset: i) {
                if !(processingPullQueue[queueUUID] ?? false) {
                    self.processingPullQueue[queueUUID] = true
                    var request = URLRequest(url: baseURL.appendingPathComponent("message").appending(queryItems: [.init(name: "id", value: queueUUID.uuidString)]))
                    request.httpMethod = "GET"
                    print(request)
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
                            
                            if let response = response as? HTTPURLResponse {
                                switch response.statusCode {
                                case 200:
                                    self.error = nil
                                default:
                                    self.error = .unknown
                                    self.processingPullQueue[queueUUID] = false
                                    return
                                }

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
                                    if repo.has(message: syncMessage) {
                                        self.pullQueue?.remove(id: syncMessage.id)
                                        self.processingPullQueue[queueUUID] = false
                                        return
                                    }
                                    
                                    try repo.create(message: syncMessage)
                                    if self.applyQueue?.add(message: syncMessage) ?? false {
                                        self.pullQueue?.remove(id: syncMessage.id)
                                    } else {
                                        try repo.setSyncedOnMessageID(id: syncMessage.id)
                                    }
                                    
                                } catch let error {
                                    print(error)
                                    fatalError()
                                    self.error = .unknown
                                }
                            }
                            
                            self.processingPullQueue[queueUUID] = false
                        }
                    }
                    
                    task.resume()
                }
            }
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
    
    private func syncMessageUser(user: User, message: SyncMessage, data: Data) -> Bool {
        switch message.action {
        case .create:
            if UserRepo().read(id: user.id) != nil {
                return true
            }
            
            let success = UserBuilder.create(user: user)
            if success {
                self.postSyncNotification(.userSyncCreated)
            }
            return success
        default:
            break
        }
        
        return false
    }
    
    private func syncMessageLabelLink(user: User, message: SyncMessage, data: Data) -> Bool {
        switch message.action {
        case .create:
            if let labelLink = try? decoder.decode(LabelLink.self, from: data) {
                if self.processLabelLink(labelLink, user: user) {
                    do {
                        let repo = SyncMessageRepo(user: user)
                        try repo.updateToIsApplied(id: message.id)
                        return true
                    } catch let error {
                        print(error)
                        return false
                    }
                } else {
                    return false
                }
            } else {
                 return false
            }
            
        case .update:
            break
        case .delete:
            break
        case .read:
            break
        }
        
        return false
    }
    
    private func syncMessageBlock(user: User, message: SyncMessage, data: Data) -> Bool {
        switch message.action {
        case .create:
            let block = try! decoder.decode(Block.self, from: data)
            guard let workspace = try? WorkspaceRepo(user: user).read(workspace: block.document.workspace) else {
                return false
            }
            
            return self.processBlock(block, workspace: workspace, user: user)
        case .update:
            let block = try! decoder.decode(Block.self, from: data)
            guard let workspace = try? WorkspaceRepo(user: user).read(workspace: block.document.workspace) else {
                return false
            }
            
            return self.updateBlock(block, workspace: workspace, user: user)
        case .delete:
            break
        case .read:
            break
        }
        
        return false
    }
    
    private func syncMessageLabel(user: User, message: SyncMessage, data: Data) -> Bool {
        switch message.action {
        case .create:
            let label = try! decoder.decode(Label.self, from: data)
            guard let workspace = try? WorkspaceRepo(user: user).read(workspace: label.workspace) else {
                return false
            }
            
            return self.processLabel(label, user: user, workspace: workspace)
        case .update:
            break
        case .delete:
            break
        case .read:
            break
        }
        
        return false
    }
    
    private func syncMessageDocument(user: User, message: SyncMessage, data: Data) -> Bool {
        switch message.action {
        case .create:
            let document = try! decoder.decode(Document.self, from: data)
            return self.processDocument(document, user: user)
        case .update:
            let documentUpdate = try! decoder.decode(DocumentUpdate.self, from: data)
            let success = updateDocument(documentUpdate, message: message, user: user)
            self.postSyncNotification(.documentUpdateReceived)
            return success
        case .delete:
            break
        case .read:
            break
        }
        
        return false
    }
    
    private func syncMessageWorkspace(user: User, message: SyncMessage, data: Data) -> Bool {
        switch message.action {
        case .create:
            let workspace = try! decoder.decode(Workspace.self, from: data)
            return self.processWorkspace(workspace, user: user)
        case .update:
            break
        case .delete:
            break
        case .read:
            break
        }
        
        return false
    }
    
    private func updateDocument(_ documentUpdate: DocumentUpdate, message: SyncMessage, user: User) -> Bool {
        
        let workspaceRepo = WorkspaceRepo(user: user)
        if let workspace = try? workspaceRepo.read(workspace: documentUpdate.workspace) {
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            guard let document = try? documentRepo.read(id: documentUpdate.id) else {
                print("document couldn't be read: \(documentUpdate.id)")
                return false
            }
            
            if document.modifiedAt < message.timestamp {
                for diff in documentUpdate.content.keys {
                    switch diff {
                    case "title":
                        if let title = documentUpdate.content["title"] {
                            let updatedDocument = Document(
                                id: document.id,
                                title: title,
                                focused: document.focused,
                                createdAt: document.createdAt,
                                modifiedAt: message.timestamp,
                                workspace: document.workspace
                            )
                            
                            if documentRepo.update(document: updatedDocument) {
                                self.postSyncNotification(.documentUpdateSynced)
                                return true
                            } else {
                                print("Document update failed")
                                return false
                            }
                            
                        }
                        
                    default:
                        return false
                        break
                    }
                }
            } else {
                print("Dropping document")
                return true
            }
        }
        
        return false
    }
    
    private func processLabelLink(_ labelLink: LabelLink, user: User) -> Bool {
        do {
            let workspaceRepo = WorkspaceRepo(user: user)
            guard let workspace = try? workspaceRepo.read(workspace: labelLink.workspace) else {
                print("Couldn't read workspace: \(labelLink.workspace)")
                return false
            }
            
            let labelRepo = LabelRepo(user: user, workspace: workspace)
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            if let document = try documentRepo.read(id: labelLink.document),
               let label = try labelRepo.read(id: labelLink.label) {
                let exists = try documentRepo.attachExists(label: label, document: document)
                if !exists {
                    if documentRepo.attach(label: label, document: document) != nil {
                        self.postSyncNotification(.labelLinkCreated)
                        return true
                    } else {
                        print("LabelLink creation failed")
                        return false
                    }
                }
            }

        } catch let error {
            print(error)
            return false
        }
        
        return false
    }
    
    private func processLabel(_ label: Label, user: User, workspace: Workspace) -> Bool {
        let labelRepo = LabelRepo(user: user, workspace: workspace)
        if try! labelRepo.create(label: label) != nil {
            self.postSyncNotification(.labelCreated)
            return true
        } else {
            print("Label creation failed")
            return false
        }
    }
    
    private func processDocument(_ doc: Document, user: User) -> Bool {
        let workspaceRepo = WorkspaceRepo(user: user)
        if workspaceRepo.create(document: doc) {
            self.postSyncNotification(.documentCreated)
            return true
        } else {
            print("Document creation failed")
            return false
        }
    }
    
    private func updateBlock(_ block: Block, workspace: Workspace, user: User) -> Bool {
        let documentRepo = DocumentRepo(user: user, workspace: workspace)
        if documentRepo.update(block: block) {
            self.postSyncNotification(.blockUpdated)
            return true
        } else {
            print("Block update failed")
            return false
        }
    }
    
    private func processBlock(_ block: Block, workspace: Workspace, user: User) -> Bool {
        do {
            let documentRepo = DocumentRepo(user: user, workspace: workspace)
            if try documentRepo.create(block: block) {
                self.postSyncNotification(.blockCreated)
                return true
            }
        } catch let error {
            print(error)
        }
        
        return false
    }
    
    private func processWorkspace(_ workspace: Workspace, user: User) -> Bool {
        let workspaceRepo = WorkspaceRepo(user: user)
        if workspaceRepo.create(workspace: workspace) {
            self.postSyncNotification(.workspaceCreated)
            return true
        } else {
            print("Workspace creation failed")
            return false
        }
    }
    
    private func processPushQueue(user: User) {
        // Push messages
        self.pushQueue?.fetchQueue()
        if let queueItem = self.pushQueue?.peek() {
            if !processingPushQueue {
                processingPushQueue = true
                if queueItem.isSynced == true {
                    self.pushQueue?.remove(id: queueItem.id)
                    processingPushQueue = false
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
                                    print("dropping \(queueItem.id)")
                                    if self.pushQueue?.remove(id: queueItem.id) == true {
                                        self.syncStatus = .success
                                        //                                        print(queueItem)
                                        self.postSyncNotification(.networkSyncSuccess)
                                    } else {
                                        fatalError()
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
                            self.processingPushQueue = false
                        }
                    }
                }
            }
        }
    }
    
    func pushMessage(user: User, message: SyncMessage) {
        if self.pushQueue != nil {
            if self.pushQueue!.add(message: message) == false {
                fatalError("push queu add failed")
            }
        } else {
            fatalError("Remove if let block and replace with ?")
        }
    }
    
    func createWorkspace(user: User, workspace: Workspace) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let contents = try! encoder.encode(workspace)
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .workspace, action: .create, isSynced: false, isApplied: true, contents: String(data: contents, encoding: .utf8)!)
        
        pushMessage(user: user, message: message)
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
        }
        
        task.resume()
    }
    
    func fetchMessageIDs(user: User) {
        let syncMessageRepo = SyncMessageRepo(user: user)
        
        if let lastSyncTime = getLastSyncTime(user: user) {
            
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
                        let lastSyncDate = Date(timeIntervalSince1970: lastSyncTime)
                        let ids = syncMessageIDsResult.ids
                        // Save ids then set sync time if successful
                        do {
                            for id in ids {
                                let uuid = UUID(uuidString: id)!
                                if !syncMessageRepo.has(id: uuid) {
                                    self.pullQueue?.add(id: uuid)
                                }
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
            DispatchQueue.global(qos: .default).sync {
                try? syncMessageRepo.setLastSyncTime(time: nil)
            }
        }
    }
}
