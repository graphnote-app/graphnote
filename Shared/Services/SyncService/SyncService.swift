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
    case unknown
}

enum SyncServiceNotification: String {
    case networkSyncFailed
    case networkSyncSuccess
    case messageIDsFetched
    case workspaceCreated
}

enum SyncServiceStatus {
    case paused
    case failed
    case success
}

class SyncService: ObservableObject {
    static let shared = SyncService()
    let syncInterval = 0.25
    @Published private(set) var statusCode: Int = 200
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

    private(set) var watching = false
    private var timer: Timer? = nil
    private var requestIDs: Set<UUID> = Set()
    
    private lazy var queue: SyncQueue? = nil
    
    private func getLastSyncTime(user: User) -> Date? {
        let syncMessageRepo = SyncMessageRepo(user: user)
        return try? syncMessageRepo.readLastSyncTime()
    }
    
    func startQueue(user: User) {
        if queue == nil {
            self.queue = SyncQueue(user: user)
        }
        
        // Invalidate timer always so we don't get runaway timers
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { timer in
            self.processQueue(user: user)
        }

        watching = true
    }
    
    func stopQueue() {
        self.timer?.invalidate()
        self.timer = nil
        watching = false
    }
    
    private func postSyncNotification(_ notification: SyncServiceNotification) {
        NotificationCenter.default.post(name: Notification.Name(notification.rawValue), object: nil)
    }
    
    func processMessageIDs(user: User) {
        // Pull messages
        
        let syncMessageRepo = SyncMessageRepo(user: user)
        guard let ids = syncMessageRepo.readAllIDs(includeSynced: false) else {
            return
        }
        print("ids: \(ids)")
        
        // TODO: Batch pulls
        for id in ids {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            var request = URLRequest(url: self.baseURL.appendingPathComponent("message").appending(queryItems: [.init(name: "id", value: id.uuidString)]))
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
                        let decoder = JSONDecoder()
                        let formatter = DateFormatter()
                        formatter.calendar = Calendar(identifier: .iso8601)
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        decoder.dateDecodingStrategy = .millisecondsSince1970
                        
                        do {
                            let syncMessage = try decoder.decode(SyncMessage.self, from: data)
                            
                            
                            if let contentsData = syncMessage.contents.data(using: .utf8) {
                                self.createMessage(user: user, message: syncMessage)
                                switch syncMessage.type {
                                case .user:
                                    break
                                case .document:
                                    let document = try! decoder.decode(Document.self, from: contentsData)
                                    let workspaceRepo = WorkspaceRepo(user: user)
                                    try! workspaceRepo.create(document: document, for: user)
                                case .workspace:
                                    print("contents here: \(syncMessage.contents)")
                                    let workspace = try! decoder.decode(Workspace.self, from: contentsData)
                                    let userRepo = UserRepo()
                                    try! userRepo.create(workspace: workspace, for: user)
                                    self.postSyncNotification(.workspaceCreated)
                                }
                                try syncMessageRepo.setSyncedOnMessageID(id: syncMessage.id)
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
    
    private func processQueue(user: User) {
        // Push messages
        if let queueItem = self.queue?.peek() {
            if queueItem.isSynced == true {
                self.queue?.remove(id: queueItem.id)
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
                                if self.queue?.remove(id: queueItem.id) != nil {
                                    self.syncStatus = .success
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
    
    let baseURL = URL(string: "http://10.0.0.207:3000/")!
    
    enum HTTPMethod: String {
        case post
        case get
    }
    
    func dbHas(message: SyncMessage) -> Bool {
        return true
    }
    
    func createMessage(user: User, message: SyncMessage) -> Bool {
        let repo = SyncMessageRepo(user: user)
        if let _ = try? repo.create(message: message) {
            return true
        } else {
            return false
        }
    }
    
    func createWorkspace(user: User, workspace: Workspace) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let contents = try! encoder.encode(workspace)
        print("contents: \(contents)")
//        let json = try! JSONSerialization.jsonObject(with: contents) as! Dictionary<String, Any>
//        print(json)
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .workspace, action: .create, isSynced: false, contents: String(data: contents, encoding: .utf8)!)
        
        // Save message to local queue
        print(self.queue?.add(message: message))
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
        
        // Save message to local queue
        print(self.queue?.add(message: message))
        
    }
    
    func createDocument(user: User, document: Document) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let contents = try! encoder.encode(document)

        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .create, isSynced: false, contents: String(data: contents, encoding: .utf8)!)
        
        // Save message to local queue
        print(self.queue?.add(message: message))
        
        let workspaceRepo = WorkspaceRepo(user: user)
        try? workspaceRepo.create(document: document, for: user)
        
    }
    
    func fetchMessageIDs(user: User) {
        let syncMessageRepo = SyncMessageRepo(user: user)
        
        if let lastSyncTime = getLastSyncTime(user: user) {
            print(lastSyncTime.timeIntervalSince1970)
            
            var request = URLRequest(url: baseURL.appendingPathComponent("message/ids")
                .appending(queryItems: [.init(name: "user", value: user.id), .init(name: "last", value: String(lastSyncTime.timeIntervalSince1970))]))
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error {
                    print(error)
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print(response)
                    
                    switch response.statusCode {
                    case 200:
                        break
                    default:
                        print(response.statusCode)
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
                    
                    print(ids)
                    
                    // Save ids then set sync time if successful
                    do {
                        for id in ids {
                            try syncMessageRepo.create(id: UUID(uuidString: id)!)
                        }
                        
                        try syncMessageRepo.setLastSyncTime(time: lastSyncDate)
                        DispatchQueue.main.async {
                            self.postSyncNotification(.messageIDsFetched)
                        }
                        
                    } catch let error {
                        print(error)
                    }
                    
                }
            }
            
            task.resume()
        } else {
            try? syncMessageRepo.setLastSyncTime(time: nil)
        }
        
    }
    
    func fetchUser(id: String, callback: @escaping (_ user: User?, _ error: SyncServiceError?) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("user")
            .appending(queryItems: [.init(name: "id", value: id)]))
        request.httpMethod = "GET"
        print("SyncService fetchUser fetching: \(id)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
                callback(nil, SyncServiceError.postFailed)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
                print(response)
                switch response.statusCode {
                case 200:
                    if let data {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .millisecondsSince1970

                        do {
                            let user = try decoder.decode(User.self, from: data)
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
}
