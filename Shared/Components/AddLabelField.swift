//
//  AddLabelField.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/24/23.
//

import SwiftUI

struct AddLabelField: View {
    let user: User
    let workspace: Workspace
    var labels: [Label]
    let allLabels: [Label]
    let addLabel: (Label) -> Void
    
    private let pad = 8.0
    @State private var addLabelText = ""
    @State private var isSuggestionsPopoverPresented = false
    
    var body: some View {
        TextField("Add label", text: $addLabelText)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.gray)
            .onChange(of: addLabelText) { newValue in
                if allLabels.filter({$0.title.contains(addLabelText)}).first != nil {
                    isSuggestionsPopoverPresented = true
                }
            }
            .onSubmit {
                if !addLabelText.isEmpty {
                    let now = Date.now
                    addLabel(Label(id: UUID(), title: addLabelText, color: LabelPalette.allCases().randomElement()!, workspace: workspace.id, user: user.id, createdAt: now, modifiedAt: now))
                    addLabelText = ""
                }
                
            }
            .popover(isPresented: $isSuggestionsPopoverPresented, arrowEdge: .bottom) {
                if let suggestionLabels = allLabels.filter {$0.title.contains(addLabelText)} {
                    
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(suggestionLabels, id: \.id) { suggestion in
                                LabelView(label: suggestion) { _ in
                                    
                                }
                                .padding()
                                .onTapGesture {
                                    addLabel(suggestion)
                                    addLabelText = ""
                                    isSuggestionsPopoverPresented = false
                                }
                                .fixedSize()
                            }
                        }
                    }
                    
                }
            }
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(labels, id: \.id) { label in
                        LabelView(label: label) { newValue in
                            
                        }
                    }
                }
                .cornerRadius(pad)
                Spacer()
            }
            .frame(width: proxy.size.width - pad * 2, height: Spacing.spacing6.rawValue)
            .padding(pad)
        }
        
        
        .foregroundColor(.black)
        
        Spacer()

    }
}
