//
//  TreeViewLine.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/21/23.
//

import SwiftUI

struct TreeViewLine: View {
    let id: UUID
    let color: Color
    let toggle: Bool
    let label: String
    let isAll: Bool
    
    init(id: UUID, color: Color, toggle: Bool, label: String, isAll: Bool = false) {
        self.id = id
        self.color = color
        self.toggle = toggle
        self.label = label
        self.isAll = isAll
    }
    
    var body: some View {
        HStack {
            ArrowView(color: color, down: toggle)
                .frame(width: TreeViewLabelDimensions.arrowWidthHeight.rawValue, height: TreeViewLabelDimensions.arrowWidthHeight.rawValue)
            if isAll {
                TreeDocView()
                    .foregroundColor(color)
                    .padding(TreeViewLabelDimensions.rowPadding.rawValue)
            } else {
                TreeTagView()
                    .foregroundColor(color)
                    .padding(TreeViewLabelDimensions.rowPadding.rawValue)
            }

            Text(label)
                .bold()
                .padding(TreeViewLabelDimensions.rowPadding.rawValue)
        }
        .contentShape(Rectangle())
    }
}

struct TreeViewLine_Previews: PreviewProvider {
    static var previews: some View {
        TreeViewLine(id: UUID(), color: .red, toggle: false, label: "Preview")
    }
}
