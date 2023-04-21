//
//  BodyView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 3/12/23.
//

import SwiftUI

fileprivate let bodyFontSize: CGFloat = 18.0

struct BodyView: View {
    let text: String
    let textDidChange: (_ text: String) -> Void
    
    @State private var content: String
    
    init(text: String, textDidChange: @escaping (_: String) -> Void) {
        self.text = text
        self.textDidChange = textDidChange
        self.content = text
    }
    
    var body: some View {
        #if os(macOS)
        TextField("", text: $content, axis: .vertical)
            .frame(maxWidth: .infinity)
            .textFieldStyle(.plain)
            .font(.system(size: bodyFontSize))
            .onAppear {
                content = text
            }
            .onChange(of: content) { newValue in
                textDidChange(newValue)
            }
        
        #else
        TextField("", text: $content, axis: .vertical)
            .onAppear {
                content = text
            }
            .onChange(of: content) { newValue in
                textDidChange(newValue)
            }
        #endif
    }
}

struct BodyView_Previews: PreviewProvider {
    static var previews: some View {
        BodyView(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.") { _ in 
            
        }
    }
}
