//
//  HeadingView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/12/23.
//

import SwiftUI

struct HeadingView: View {
    
    let size: HeadingSize
    let text: String
    
    enum HeadingSize: Int {
        case heading1 = 40
        case heading2 = 32
        case heading3 = 24
        case heading4 = 18
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: CGFloat(size.rawValue)))
            .bold()
    }
}
