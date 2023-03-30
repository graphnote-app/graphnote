//
//  GlobalDimension.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import Foundation

#if os(macOS)
typealias GlobalDimension = GlobalDimensionMacOS
#else
typealias GlobalDimension = GlobalDimensionIOS
#endif
