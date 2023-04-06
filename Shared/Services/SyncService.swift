//
//  SyncService.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/4/23.
//

import Foundation

struct SyncService {
    static let shared = SyncService()
    
    let baseURL = URL(string: "http://10.0.0.207:3000/")!
    
    func createUser(user: User, callback: @escaping (_ response: HTTPURLResponse) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("user"))
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpMethod = "POST"
        request.httpBody = try! encoder.encode(user)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                callback(response)
            }
            
            if let data {
                print(data)
            }
        }
        
        task.resume()
    }
    
    func fetchUser(id: String, callback: @escaping (_ user: User?) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("user")
            .appending(queryItems: [.init(name: "id", value: id)]))
        request.httpMethod = "GET"
        print("SyncService fetchUser fetching: \(id)")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
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
                            callback(user)
                        } catch let error {
                            print(error)
                            callback(nil)
                        }
                        
                    }
                case 404:
                    callback(nil)
                default:
                    print("Response failed with statusCode: \(response.statusCode)")
                    callback(nil)
                }
                
            }
        }
        
        task.resume()
    }
}
