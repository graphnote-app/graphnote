//
//  TreeViewLabel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData
import Combine

enum TreeViewLabelDimensions: CGFloat {
    case arrowWidthHeight = 16
    case rowPadding = 4
}

enum FocusField: Hashable {
   case field
}

struct TreeViewLabel: View, Identifiable {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var toggle = false
    @State private var editable = false
    @FocusState private var focusedField: FocusField?
    
    let id: UUID
    @Binding var label: String
    let color: Color
    let content: () -> any View

    var body: some View {
        VStack(alignment: .leading) {
            TreeViewLine(id: UUID(), color: color, toggle: toggle, label: label)
                .padding(TreeViewLabelDimensions.rowPadding.rawValue)
                .frame(minWidth: 200, alignment: .leading)
                .contentShape(RoundedRectangle(cornerRadius: Spacing.spacing2.rawValue))
//                .contextMenu {
//                    Button {
//                        editable = true
//                    } label: {
//                        Text("Rename label")
//                    }
//                }
                .onTapGesture {
                    toggle.toggle()
                }
                
            if toggle {
                VStack(alignment: .leading) {
                    AnyView(content())
                }
                .padding([.leading], 40)
            }
        }
        
        
    }
}
