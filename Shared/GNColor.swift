//
//  GNColor.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import Foundation

struct GNColorComponents {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
}

#if os(macOS)
import Cocoa
typealias GNColor = NSColor

extension GNColor {
    func getColorComponents() -> GNColorComponents {
        return GNColorComponents(red: self.redComponent, green: self.greenComponent, blue: self.blueComponent)
    }
}

#else
import UIKit
typealias GNColor = UIColor

extension GNColor {
    func getColorComponents() -> GNColorComponents {
        let components = self.cgColor.components!
        return GNColorComponents(red: components[0], green: components[1], blue: components[2])
    }
}

#endif
