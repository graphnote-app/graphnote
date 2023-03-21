//
//  TreeView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct TreeView: View {
    @Binding var labels: [String]
    let labelColors: [Color]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<labels.count, id: \.self) { i in
                TreeViewLabel(id: UUID(), label: $labels[i], color: labelColors[i]) {
                    
                }
            }
        }
        .padding([.top, .bottom])
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        TreeView(labels: .constant(["Test"]), labelColors: [Color.accentColor])
    }
}
