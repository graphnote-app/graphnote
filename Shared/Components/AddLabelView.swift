//
//  AddLabelView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI

struct AddLabelView: View {
    let user: User
    let workspace: Workspace
    let allLabels: [Label]
    let save: (_ labels: [Label]) -> Void
    let close: () -> Void
    
    @State private var isEmpty = true
    @State private var color = LabelPalette.allCases().randomElement()!
    @State private var title = ""
    
    @State private var labels: [Label] = []
    
    var body: some View {
        VStack {
            #if os(macOS)
            VStack(alignment: .leading) {
                AddLabelField(user: user, workspace: workspace, labels: labels, allLabels: allLabels) { label in
                    labels.append(label)
                }
                .padding([.top, .bottom])
                .textFieldStyle(.roundedBorder)
//                .frame(width: 220)
            }
            .padding()
            .cornerRadius(24)
            .onChange(of: labels, perform: { newValue in
                if newValue.count == .zero {
                    isEmpty = true
                } else {
                    isEmpty = false
                }
            })
            #else

            AddLabelField(user: user, workspace: workspace, labels: labels, allLabels: allLabels) { label in
                labels.append(label)
            }
            .padding([.top, .bottom])
            .textFieldStyle(.roundedBorder)
            .padding()
            .cornerRadius(24)
            .onChange(of: labels, perform: { newValue in
                if newValue.count == .zero {
                    isEmpty = true
                } else {
                    isEmpty = false
                }
            })
            #endif
            Spacer()
            HStack {
                Button("Close") {
                    close()
                }
                .foregroundColor(.red)
                .buttonStyle(.borderless)
                .padding()
                Spacer()
                Button("Add") {
                    save(labels)
                }
                .disabled(isEmpty)
                .foregroundColor(isEmpty ? Color.gray : Color.accentColor)
                .buttonStyle(.borderless)
                .padding()
            }.padding()
        }
    }
}
