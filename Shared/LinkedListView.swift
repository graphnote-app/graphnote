//
//  LinkedListView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/28/23.
//

import SwiftUI

struct NodeView: View, Hashable {
    let id: UUID
    let type: String
    let graveyard: Bool
    let content: String
    let prev: UUID?
    let next: UUID?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("prev: \(prev?.uuidString ?? "")")
            Text(type)
            Text("id: \(id.uuidString)")
            Text(content)
            Text("next: \(next?.uuidString ?? "")")
        }
        .frame(width: 300, alignment: .leading)
        .padding()
        .background(graveyard ? Color.gray : content == "SENTINEL BLOCK" ? Color.green : Color.accentColor)
        .cornerRadius(Spacing.spacing3.rawValue)
    }
}

struct LinkedListView: View {
    let nodes: [NodeView]
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(nodes, id: \.self) { node in
                    node
                }
            }
        }
    }
}

struct LinkedListView_Previews: PreviewProvider {
    static var previews: some View {
        LinkedListView(nodes: [
            NodeView(id: UUID(), type: "prompt", graveyard: false, content: "Testing prompt", prev: nil, next: nil),
            NodeView(id: UUID(), type: "body", graveyard: true, content: "Testing body", prev: nil, next: nil)
        ])
    }
}
