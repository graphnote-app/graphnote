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
    
    var body: some View {
        Text(text)
            .font(.system(size: bodyFontSize))
    }
}

struct BodyView_Previews: PreviewProvider {
    static var previews: some View {
        BodyView(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")
    }
}
