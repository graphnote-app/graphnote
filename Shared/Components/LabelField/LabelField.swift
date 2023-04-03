//
//  LabelField.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

enum LabelNotification: String {
    case newLabel
}

struct LabelField: View {
    @State private var editing = false
    @State private var selectedLabel: Label?
    @State private var showAddSheet = false
    @State private var labelExistsAlertOpen = false
    
    let fetch: () -> Void
    @Binding var labels: [Label]
    let user: User
    let workspace: Workspace
    let document: Document
    
    func newLabelNotification() {
        NotificationCenter.default.post(name: Notification.Name(LabelNotification.newLabel.rawValue), object: nil)
    }
    
    var body: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(labels, id: \.self) { label in
                        LabelView(label: label) { newName in
                            
                        }
                    }
                }
            }
            Spacer()
                .frame(width: Spacing.spacing1.rawValue)
            AddIconView()
                .sheet(isPresented: $showAddSheet, content: {
                    AddLabelView(save: { (title, color) in
                        let labelRepo = LabelRepo(user: user, workspace: workspace)
                        
                        var label = Label(id: UUID(), title: title, color: color, workspaceId: workspace.id, createdAt: .now, modifiedAt: .now)
                        
                        if let labelEntity = try? labelRepo.create(label: label) {
                            label = Label(id: labelEntity.id, title: label.title, color: label.color, workspaceId: label.workspaceId, createdAt: label.createdAt, modifiedAt: label.modifiedAt)    
                        }
                        
                        let documentRepo = DocumentRepo(user: user, workspace: workspace)
                        documentRepo.attach(label: label, document: document)
                        fetch()
                        newLabelNotification()
                        self.showAddSheet = false
                        
                    }, close: {
                        self.showAddSheet = false
                    })
                    .id(document.id)
                    .presentationDetents([.medium, .large])
                    .frame(width: 300, height: 260)
                })
                .alert("Label already exists!", isPresented: $labelExistsAlertOpen, actions: {
                    
                })
                .onTapGesture {
                    showAddSheet = true
                }
            Spacer(minLength: Spacing.spacing4.rawValue)
        }
    }
}
