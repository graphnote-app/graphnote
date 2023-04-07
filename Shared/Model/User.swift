//
//  User.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import Foundation

public struct User: Codable, Equatable {
    public let id: String
    public let email: String
    public let givenName: String?
    public let familyName: String?
    public let createdAt: Date
    public let modifiedAt: Date
}
