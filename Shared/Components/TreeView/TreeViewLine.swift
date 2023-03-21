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
    
    var body: some View {
        HStack {
            if toggle {
                ArrowView(color: color)
                    .frame(width: TreeViewLabelDimensions.arrowWidthHeight.rawValue, height: TreeViewLabelDimensions.arrowWidthHeight.rawValue)
                    .rotationEffect(Angle(degrees: 90))
                
            } else {
                ArrowView(color: color)
                    .frame(width: TreeViewLabelDimensions.arrowWidthHeight.rawValue, height: TreeViewLabelDimensions.arrowWidthHeight.rawValue)
            }
            
            FileIconView()
                .foregroundColor(color)
                .padding(TreeViewLabelDimensions.rowPadding.rawValue)
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
