//
//  SidebarView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct SidebarView: View {
    @Binding var items: [TreeViewItem]
    @Binding var settingsOpen: Bool
    let workspaceTitles: [String]
    @Binding var selectedWorkspaceTitleIndex: Int
    @Binding var selectedSubItem: TreeDocumentIdentifier?
    let allID: UUID
    let newDocument: () -> Void
    let refresh: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(maxHeight: Spacing.spacing7.rawValue)
            VStack(alignment: .leading) {
                TreeView(selectedSubItem: $selectedSubItem, allID: allID, items: items) {
                    refresh()
                }
                
            }
            .padding(Spacing.spacing3.rawValue)
            Spacer()
            Group {
                Button {
                    newDocument()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("New Document")
                    }
                    .frame(height: Spacing.spacing7.rawValue)
                }
                .buttonStyle(.plain)
                .padding(Spacing.spacing3.rawValue)
                HStack {
                    GearIconVIew {
                        settingsOpen = true
                    }
                    .frame(height: Spacing.spacing7.rawValue)
                    WorkspaceMenu(selectedIndex: $selectedWorkspaceTitleIndex, workspaceTitles: workspaceTitles)
                        .id("\(selectedWorkspaceTitleIndex):\(workspaceTitles)".hashValue)
                        .frame(height: Spacing.spacing7.rawValue)
                }
                .padding(Spacing.spacing3.rawValue)
            }
        }
    }
}
