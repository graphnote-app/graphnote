//
//  ArrowView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/19/22.
//

import SwiftUI

struct ArrowView: View {
    let color: Color
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                
            Arrow()
                .padding(2)
                .foregroundColor(color)
        }
        
    }
}

struct ArrowView_Previews: PreviewProvider {
    static var previews: some View {
        ArrowView(color: .blue)
    }
}
