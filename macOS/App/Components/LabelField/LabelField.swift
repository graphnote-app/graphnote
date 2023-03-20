//
//  LabelField.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct LabelField: View {
    @State private var editing = false
    
    @Binding var labels: [String]
    
    private let allColors: [Color] = [
        LabelPalette.orangeLight,
        LabelPalette.primary,
        LabelPalette.pink,
        LabelPalette.orangeDark,
        LabelPalette.yellow,
        LabelPalette.purple
    ]
    
    var body: some View {
        if editing {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.spacing8.rawValue) {
                        ForEach(0..<allColors.count, id: \.self) { i in
                            Label(fill: allColors[i], text: labels[i])
                        }
                        
                        
                    }

                    
                }.padding(Spacing.spacing2.rawValue)
                    .border(.gray)
                Spacer()
                XMarkIconView()
                    .onTapGesture {
                        editing = false
                    }
                CheckmarkIconView()
                    .onTapGesture {
                        editing = false
                    }
            }
        } else {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<allColors.count, id: \.self) { i in
                            Label(fill: allColors[i], text: labels[i])
                        }
                        Label(fill: allColors[0], text: labels[0])
                        Label(fill: allColors[0], text: labels[0])
                        Label(fill: allColors[0], text: labels[0])
                        Label(fill: allColors[0], text: labels[0])
                        Label(fill: allColors[0], text: labels[0])
                    }
                }
                
                Spacer()
                EditIconView()
                    .onTapGesture {
                        editing = true
                    }
            }
        }
        
    }
}

struct LabelField_Previews: PreviewProvider {
    static var previews: some View {
        LabelField(labels: .constant([]))
    }
}
