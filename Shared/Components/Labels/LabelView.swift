//
//  LabelView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct LabelView: View {
    let color: Color
    let text: String
    let fill: Bool
    
    init(color: Color, text: String, fill: Bool = false) {
        self.color = color
        self.text = text
        self.fill = fill
    }
    
    var body: some View {
        let height = 24.0
        let minWidth = 60.0
        
        if fill {
            Text(text)
                .font(.title3)
                .foregroundColor(Color.black)
                .lineLimit(1)
                .bold()
                .padding([.leading, .trailing], Spacing.spacing2.rawValue)
                .padding([.top, .bottom], Spacing.spacing0.rawValue)
                .frame(minWidth: minWidth)
                .frame(height: height)
                .background(RoundedRectangle(cornerRadius: height).fill(color))
        } else {
            Text(text)
                .font(.title3)
                .bold()
                .lineLimit(1)
                .padding([.leading, .trailing], Spacing.spacing2.rawValue)
                .padding([.top, .bottom], Spacing.spacing0.rawValue)
                .frame(minWidth: minWidth)
                .frame(height: height)
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
        LabelView(color: .red, text: "WIP")
    }
}
