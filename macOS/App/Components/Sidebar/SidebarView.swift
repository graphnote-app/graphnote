//
//  SidebarView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct SidebarView: View {
    @Binding var items: [TreeViewItem]
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: Spacing.spacing7.rawValue)
            VStack(alignment: .leading) {
                TreeView(items: items)
                
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Document")
                    }
                }.buttonStyle(.plain)

            }
            .padding()
            Spacer()
            WorkspaceMenu()
                .padding(Spacing.spacing3.rawValue)
        }
    }
}
