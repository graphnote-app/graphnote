//
//  DataSeeder.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/26/23.
//

import SwiftUI

struct DataSeeder: EnvironmentKey {
    static let defaultValue: Bool = false
    
    static func seed() {
        
    }
}

extension EnvironmentValues {
    var isSeeding: Bool {
        get {
            self[DataSeeder.self]
        }
        set {
            self[DataSeeder.self] = newValue
        }
    }
}
