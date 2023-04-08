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
    
    func startQueue(user: User) {
        if queue == nil {
            self.queue = SyncQueue(user: user)
        }
        
        // Invalidate timer always so we don't get runaway timers
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: syncInterval, repeats: true) { timer in
            self.processQueue()
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
    
    private func processQueue() {
        if let queueItem = self.queue?.peek() {
            if !requestIDs.contains(queueItem.id) {
                requestIDs.insert(queueItem.id)
                request(message: queueItem) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let response):
                            switch response.statusCode {
                            case 201, 409:
                                // Drop the item from the queue
                                self.queue?.remove(id: queueItem.id)
                                self.syncStatus = .success
                                self.postSyncNotification(.networkSyncSuccess)
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
    
    func request(message: SyncMessage, callback: @escaping (_ result: Result<HTTPURLResponse, SyncServiceError>) -> Void) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
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
        encoder.dateEncodingStrategy = .iso8601
        let contents = try! encoder.encode(user)
        
//        let json = try! JSONSerialization.jsonObject(with: contents) as! Dictionary<String, Any>
//        print(json)
        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .user, action: .create, isSynced: false, contents: String(data: contents, encoding: .utf8)!)
        
        // Save message to local queue
        print(self.queue?.add(message: message))
        
    }
    
    func createDocument(user: User, document: Document, workspace: Workspace) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let contents = try! encoder.encode(document)

        let message = SyncMessage(id: UUID(), user: user.id, timestamp: .now, type: .document, action: .create, isSynced: false, contents: String(data: contents, encoding: .utf8)!)
        
        // Save message to local queue
        print(self.queue?.add(message: message))
        
        let workspaceRepo = WorkspaceRepo(user: user)
        try? workspaceRepo.create(document: document, in: workspace, for: user)
        
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

                        let formatter = DateFormatter()
                        formatter.calendar = Calendar(identifier: .iso8601)
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)

                        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                            let container = try decoder.singleValueContainer()
                            let dateStr = try container.decode(String.self)

                            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
                            guard let date = formatter.date(from: dateStr) else {
                                print("Date parsing FAILED!")
                                return .now
                            }
                            
                            return date
        
                        })
                        
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
