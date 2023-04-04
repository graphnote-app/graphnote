//
//  AddLabelView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/2/23.
//

import SwiftUI

struct AddLabelView: View {
    let save: (_ title: String, Color) -> Void
    let close: () -> Void
    
    @State private var isEmpty = true
    @State private var color = LabelPalette.allCases().randomElement()
    
    @State private var title: String = ""
    
    var content: some View {
        VStack {
            List {
                TextField("name", text: $title)
                    .padding([.top, .bottom])
                    .textFieldStyle(.roundedBorder)
                Menu("label color") {
                    ForEach(LabelPalette.allCases(), id: \.self) { color in
                        Button(color.rawValue) {
                            self.color = color
                        }
                    }
                }
                .menuStyle(.borderedButton)
                .onChange(of: title, perform: { newValue in
                    if newValue.count == .zero {
                        isEmpty = true
                    } else {
                        isEmpty = false
                    }
                })
                
            }
            .listStyle(.inset)
            .cornerRadius(24)
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
                    save(title, color!.getColor())
                }
                .disabled(isEmpty)
                .foregroundColor(isEmpty ? Color.gray : Color.accentColor)
                .buttonStyle(.borderless)
                .padding()
            }.padding()
        }
    }
    
    var body: some View {
        #if os(macOS)
        content
            .frame(width: 300, height: 200)
        #else
        content
            .frame(width: 300, height: 300)
        #endif
    }
}

struct AddLabelView_Previews: PreviewProvider {
    static var previews: some View {
        AddLabelView { title, color in
            
        } close: {
            
        }

    }
}
