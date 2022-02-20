//
//  ArrowView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.size.height / 2))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.size.height))
        path.closeSubpath()
        return path
    }
}

struct Arrow_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Arrow()
        }
        
    }
}
