//
//  GlobalDimensionMacOS.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import Foundation

struct GlobalDimensionMacOS {
    static let treeWidth: CGFloat = 250
    static let toolbarWidth = Spacing.spacing4.rawValue + (Spacing.spacing3.rawValue * 2)
    static let maxDocumentContentWidth = 800.0
    static let minDocumentContentWidth = 400.0
    static let minDocumentContentHeight = 300.0
    static let minDocumentPreviewContentWidth = 450.0
    static let maxDocumentPreviewContentWidth = 250.0
    static let windowMinimumWidth = 850.0
    static let windowMinimumHeight = 550.0
    static let windowDefaultWidth = 1038.0
    static let windowDefaultHeight = 600.0
    static let iconSmall = 16.0
    static let modalWidth = 550.0
    static let modalHeight = 525.0
    static let labelModalWidth = 500.0
    static let labelModalHeight = 400.0
}
