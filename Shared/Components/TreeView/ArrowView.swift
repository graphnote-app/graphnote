//
//  ArrowView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/19/22.
//

import SwiftUI

struct ArrowView: View {
    let color: Color
    let down: Bool
    
    var body: some View {
        Image(systemName: down ? "arrowtriangle.down.fill" : "arrowtriangle.right.fill")
            .renderingMode(.template)
            .padding()
            .foregroundColor(color)
    }
}

struct ArrowView_Previews: PreviewProvider {
    static var previews: some View {
        ArrowView(color: .blue, down: false)
    }
}
