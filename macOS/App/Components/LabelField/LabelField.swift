//
//  LabelField.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct LabelField: View {
    @State private var editing = false
    @State private var selectedLabel: Label?
    
    @Binding var labels: [Label]
    
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
                .onTapGesture {
                    let newLabel = Label(id: UUID(), title: "New label", color: LabelPalette.allColors.randomElement()!)
                    labels.append(newLabel)
                    selectedLabel = newLabel
                }
            Spacer(minLength: Spacing.spacing4.rawValue)
        }
    }
}

struct LabelField_Previews: PreviewProvider {
    static var previews: some View {
        LabelField(labels: .constant([]))
    }
}
