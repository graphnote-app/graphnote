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
                .frame(maxWidth: GlobalDimension.maxDocumentContentWidth)
            #endif
            Spacer()
        }
        .padding([.top, .bottom])
    }
}

struct HorizontalFlexPreviewView: View {
    let content: () -> any View
    
    var body: some View {
        HStack {
            Spacer()
            #if os(macOS)
            AnyView(content())
                .frame(maxWidth: .infinity)
//                .frame(minWidth: GlobalDimension.minDocumentPreviewContentWidth)
//                .frame(maxWidth: GlobalDimensio/n.maxDocumentPreviewContentWidth)
            #else
            AnyView(content())
            #endif
            Spacer()
        }
        .padding([.top, .bottom])
    }
}

