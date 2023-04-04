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
    
    private let labelService: LabelService
    
    let fetch: () -> Void
    @Binding var labels: [Label]
    let user: User
    let workspace: Workspace
    let document: Document
    
    init(fetch: @escaping () -> Void, labels: Binding<[Label]>, user: User, workspace: Workspace, document: Document) {
        self.labelService = LabelService(user: user, workspace: workspace)
        self.fetch = fetch
        self._labels = labels
        self.user = user
        self.workspace = workspace
        self.document = document
    }
    
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
                        
                        if let added = try? labelService.addLabel(title: title, color: color, document: document) {
                            if added {
                                newLabelNotification()
                                fetch()
                                self.showAddSheet = false
                                
                            } else {
                                self.showAddSheet = false
                                labelExistsAlertOpen = true
                            }
                            
                        } else {
                            fetch()
                            self.showAddSheet = false
                        }
                        
                    }, close: {
                        self.showAddSheet = false
                    })
                    .id(document.id)
                    .presentationDetents([.medium, .large])
//                    .frame(width: 300, height: 260)
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
