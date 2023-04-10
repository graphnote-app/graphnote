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
    
    var menu: some View {
        Menu {
            ForEach(LabelPalette.allCases(), id: \.self) { color in
                Button(color.rawValue) {
                    self.color = color
                }
            }
        } label: {
            Text(self.color.rawValue)
        }
        .onChange(of: title, perform: { newValue in
            if newValue.count == .zero {
                isEmpty = true
            } else {
                isEmpty = false
            }
        })
    }
    
    var body: some View {
        VStack {
            #if os(macOS)
            VStack(alignment: .leading) {
                TextField("name", text: $title)
                    .padding([.top, .bottom])
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 220)
                menu
                    .menuStyle(.borderedButton)

            }
            .padding()
            .cornerRadius(24)
            #else
            List {
                TextField("name", text: $title)
                    .padding([.top, .bottom])
                    .textFieldStyle(.roundedBorder)
                
                menu
                    .menuStyle(.borderlessButton)
            }
            .listStyle(.insetGrouped)
            .padding()
            .cornerRadius(24)
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
