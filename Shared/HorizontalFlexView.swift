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
            #if os(macOS)
            AnyView(content())
                .frame(minWidth: GlobalDimension.minDocumentContentWidth)
                .frame(maxWidth: GlobalDimension.maxDocumentContentWidth)
            #else
            AnyView(content())
            #endif
            Spacer()
        }
        .padding([.top, .bottom])
    }
}
