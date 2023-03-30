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
    let textDidChange: (_ text: String) -> Void
    
    enum HeadingSize: Int {
        case heading1 = 40
        case heading2 = 32
        case heading3 = 24
        case heading4 = 18
    }
    
    init(size: HeadingSize, text: String, textDidChange: @escaping (_: String) -> Void) {
        self.size = size
        self.text = text
        self.textDidChange = textDidChange
        self.content = text
    }
    
    @State private var content: String
    
    var body: some View {
        TextField("", text: $content, axis: .vertical)
            .textFieldStyle(.plain)
            .font(.system(size: CGFloat(size.rawValue)))
            .onAppear {
                content = text
            }
            .onChange(of: content) { newValue in
                textDidChange(newValue)
            }
    }
}
