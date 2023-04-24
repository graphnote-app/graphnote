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
    
    var body: some View {
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
        TextField("Add label", text: $addLabelText)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.gray)
            .searchable(text: $addLabelText)
            .searchSuggestions({
                ForEach(allLabels, id: \.id) { label in
                    Text(label.title).searchCompletion(label.title)
                }
            })
            .onSubmit {
                if !addLabelText.isEmpty {
                    let now = Date.now
                    addLabel(Label(id: UUID(), title: addLabelText, color: LabelPalette.allCases().randomElement()!, workspace: workspace.id, user: user.id, createdAt: now, modifiedAt: now))
                }
                
            }
        Spacer()

    }
}
