//
//  Label.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/20/23.
//

import SwiftUI

struct Label: View {
    let fill: Color
    let text: String
    
    var body: some View {
        let height = 30.0
        let minWidth = 100.0
        
        ZStack {
            RoundedRectangle(cornerRadius: height)
                .stroke(fill, lineWidth: 2)
                .border(.clear)
                .frame(minWidth: minWidth)
                .frame(height: height)
                .fixedSize()
            Text(text)
                .bold()
                .lineLimit(1)
        }
    }
}

struct Label_Previews: PreviewProvider {
    static var previews: some View {
        Label(fill: .red, text: "WIP")
    }
}
