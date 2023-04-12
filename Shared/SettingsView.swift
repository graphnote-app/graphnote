//
//  SettingsView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/21/23.
//

import SwiftUI

struct SettingsView: View {
    let user: User
    
    var content: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: Spacing.spacing4.rawValue)
            HStack {
                Text("Account")
                    .font(.title)
                    .bold()
                Spacer()
                
            }
            Button {
                let now = Date.now
                let workspace = Workspace(
                        id: UUID(),
                        title: "New workspace",
                        createdAt: now,
                        modifiedAt: now,
                        user: user.id,
                        labels: [],
                        documents: []
                )
                SyncService.shared.createWorkspace(user: user, workspace: workspace)
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("New Workspace")
                }
                .frame(height: Spacing.spacing7.rawValue)
            }
            .buttonStyle(.plain)
            .padding(Spacing.spacing3.rawValue)
            Spacer()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HorizontalFlexView {
                content
            }
                .frame(minHeight: geometry.size.height)
        }
    }
}

