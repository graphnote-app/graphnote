//
//  BlockType.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/12/23.
//

enum BlockType: String, Codable {
    case body
    case heading1
    case heading2
    case heading3
    case heading4
    case empty
    case bullet
    case prompt
    case contentLink
}

