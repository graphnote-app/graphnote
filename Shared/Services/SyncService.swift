//
//  SyncService.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/4/23.
//

import Foundation

struct SyncService {
    let baseURL = URL(string: "http://10.0.0.207:3000/")!
    
    func createUser(user: User, callback: @escaping (_ statusCode: Int) -> Void) {
        var request = URLRequest(url: baseURL.appendingPathComponent("user"))
        let encoder = JSONEncoder()
        request.httpMethod = "POST"
        request.httpBody = try! encoder.encode(user)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print(error)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                callback(response.statusCode)
            }
            
            if let data {
                print(data)
            }
        }
        
        task.resume()
    }
}
