//
//  HorizontalFlexView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/30/23.
//

import SwiftUI

struct HorizontalFlexView: View {
    let content: () -> any View
    
    var body: some View {
        HStack {
            Spacer()
            AnyView(content())
                .frame(minWidth: GlobalDimension.minDocumentContentWidth)
                .frame(maxWidth: GlobalDimension.maxDocumentContentWidth)
            Spacer()
        }
        .padding([.top, .bottom])
    }
}
