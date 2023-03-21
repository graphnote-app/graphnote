//
//  TreeView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct TreeView: View {
    @Binding var labels: [String]
    let labelColors: [Color]
    
    @ViewBuilder func textOrTextField(title: String) -> some View {
        HStack {
//            if editable {
//                CheckmarkView()
//                    .onTapGesture {
//                       editable = false
//                    }
//                TextField("", text: title)
//                    .onSubmit {
//                        editable = false
//                        focusedField = nil
//                    }
//                    .focused($focusedField, equals: .field)
//                    .onAppear {
//                        print("onAppear")
//                        if editable {
//                            focusedField = .field
//                        }
//                    }
//            } else {
                TreeBulletView()
//                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
                HStack {
                    Text(title)

                    Spacer()
                }.frame(width: 130)
//            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<labels.count, id: \.self) { i in
                TreeViewLabel(id: UUID(), label: $labels[i], color: labelColors[i]) {
                } content: {
                    VStack {
                        textOrTextField(title: "Testing")
                    }
                }
            }
        }
        .padding([.top, .bottom])
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        TreeView(labels: .constant(["Test"]), labelColors: [Color.accentColor])
    }
}
