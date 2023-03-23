//
//  LabelView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI
import Foundation

struct LabelView: View {
    let label: Label
    let rename: (_ name: String) -> Void
    
    enum FocusedField {
        case title
    }
    
    @State private var editing = false
    @State private var content: String = ""
    @FocusState private var focusedField: FocusedField?
    @FocusState private var isFocused: Bool
    
    init(label: Label, rename: @escaping (_: String) -> Void) {
        self.label = label
        self.rename = rename
        
        // Set the content to label.title initially and when we get updates from init
        self.content = label.title
    }
    
    var body: some View {
        let height = 24.0
        let minWidth = 60.0
        
        Form {
            if editing {
                TextField("", text: $content)
                    .font(.title3)
                    .foregroundColor(Color.black)
                    .lineLimit(1)
                    .bold()
                    .padding([.leading, .trailing], Spacing.spacing2.rawValue)
                    .padding([.top, .bottom], Spacing.spacing0.rawValue)
                    .frame(minWidth: minWidth)
                    .frame(height: height)
                    .background(RoundedRectangle(cornerRadius: height).fill(label.color))
                    .contentShape(RoundedRectangle(cornerRadius: height))
                    .focused($focusedField, equals: .title)
                    .focused($isFocused)
                    .onChange(of: isFocused, perform: { newValue in
                        if newValue == false {
                            editing = newValue
                        }
                    })
                    .onSubmit {
                        editing = false
                    }
                    .onExitCommand {
                        editing = false
                    }
                
            } else {
                Text(label.title)
                    .font(.title3)
                    .foregroundColor(Color.black)
                    .lineLimit(1)
                    .bold()
                    .padding([.leading, .trailing], Spacing.spacing2.rawValue)
                    .padding([.top, .bottom], Spacing.spacing0.rawValue)
                    .frame(minWidth: minWidth)
                    .frame(height: height)
                    .background(RoundedRectangle(cornerRadius: height).fill(label.color))
                    .contextMenu {
                        LabelContextMenu {
                            editing = true
                            focusedField = .title
                            content = label.title
                        } delete: {
                            
                        }

                    }
                    .contentShape(RoundedRectangle(cornerRadius: height))
            }
        }
    }
}

struct Label_Previews: PreviewProvider {
    static var previews: some View {
        LabelView(label: Label(id: UUID(), title: "Testing", color: .red)) { newName in
            
        }
    }
}
