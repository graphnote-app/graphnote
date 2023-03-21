//
//  Label.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct Label: View {
    let color: Color
    let text: String
    let fill: Bool
    
    init(color: Color, text: String, fill: Bool = false) {
        self.color = color
        self.text = text
        self.fill = fill
    }
    
    var body: some View {
        let height = 30.0
        let minWidth = 100.0
        
        if fill {
            Text(text)
                .foregroundColor(Color.black)
                .lineLimit(1)
                .bold()
                .padding(Spacing.spacing2.rawValue)
                .frame(minWidth: minWidth)
                .background(RoundedRectangle(cornerRadius: height).fill(color))
        } else {
            Text(text)
                .bold()
                .lineLimit(1)
                .padding(Spacing.spacing2.rawValue)
                .frame(minWidth: minWidth)
                .overlay {
                    RoundedRectangle(cornerRadius: height)
                        .stroke(color, lineWidth: 2)
                }
                .padding(Spacing.spacing2.rawValue)
        }
    }
}

struct Label_Previews: PreviewProvider {
    static var previews: some View {
        Label(color: .red, text: "WIP")
    }
}
