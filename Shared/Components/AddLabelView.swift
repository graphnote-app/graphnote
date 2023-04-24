//
//  AddLabelView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI

struct AddLabelView: View {
    let save: (_ title: String, LabelPalette) -> Void
    let close: () -> Void
    
    @State private var isEmpty = true
    @State private var color = LabelPalette.allCases().randomElement()!
    
    @State private var title: String = ""
    
    var body: some View {
        VStack {
            #if os(macOS)
            VStack(alignment: .leading) {
                TextField("name", text: $title)
                    .padding([.top, .bottom])
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 220)
            }
            .padding()
            .cornerRadius(24)
            .onChange(of: title, perform: { newValue in
                if newValue.count == .zero {
                    isEmpty = true
                } else {
                    isEmpty = false
                }
            })
            #else
            List {
                TextField("name", text: $title)
                    .padding([.top, .bottom])
                    .textFieldStyle(.roundedBorder)
            }
            .listStyle(.insetGrouped)
            .padding()
            .cornerRadius(24)
            .onChange(of: title, perform: { newValue in
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
                    save(title, color)
                }
                .disabled(isEmpty)
                .foregroundColor(isEmpty ? Color.gray : Color.accentColor)
                .buttonStyle(.borderless)
                .padding()
            }.padding()
        }
    }
}

struct AddLabelView_Previews: PreviewProvider {
    static var previews: some View {
        AddLabelView { title, color in
            
        } close: {
            
        }

    }
}
