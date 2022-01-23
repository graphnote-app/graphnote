//
//  DocumentView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/23/22.
//

import SwiftUI

fileprivate let scrollWidth: CGFloat = 16
fileprivate let pageMinHeightMultiplier = 1.3
fileprivate let maxBlockWidth: CGFloat = 800
fileprivate let pad: Double = 40

struct DocumentView: View {
    @Environment(\.colorScheme) var colorScheme
    let selected: (workspaceId: String, documentId: String)
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: true) {
                #if os(macOS)
                VStack(alignment: .leading) {
                    HStack {
                        Text("Workspace ID: \(selected.workspaceId) Document ID: \(selected.documentId)")
                            .padding(pad)
                            .foregroundColor(.primary)

                    }.frame(width: maxBlockWidth)
                    HStack {
                        Text("Header for the page and description for the document. Header for the page and description for the document.")
                            .padding(pad)
                            .foregroundColor(.primary)
                        Spacer()
                    }.frame(width: maxBlockWidth)
                    Spacer()
                }
                .frame(minWidth: geometry.size.width - scrollWidth, minHeight: geometry.size.height * pageMinHeightMultiplier)
                .background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
                #else
                VStack(alignment: .leading) {
                    Text("Workspace ID: \(selected.workspaceId) Document ID: \(selected.documentId)")
                        .frame(width: geometry.size.width / 2)
                        .padding(pad)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height * pageMinHeightMultiplier)
                .background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
                #endif
            }.background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
        }
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        let selected: (workspaceId: String, documentId: String) = ("", "")
        
        DocumentView(selected: selected)
    }
}
