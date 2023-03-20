//
//  ContentView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct ContentView: View {
    var content: some View {
        HStack {
            Spacer()
            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                .font(.title)
                .frame(minWidth: GlobalDimension.minDocumentContentWidth)
                .frame(maxWidth: GlobalDimension.maxDocumentContentWidth)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding([.top, .bottom])
        
    }
    
    var body: some View {
        SplitView {
            SidebarView()
                .frame(width: GlobalDimension.treeWidth)
        } detail: {
            ScrollView {
                Group {
                    ForEach(0..<10, id: \.self) { _ in
                        content
                    }
                }
                .padding(.trailing, GlobalDimension.toolbarWidth)
                .padding(GlobalDimension.toolbarWidth + Spacing.spacing1.rawValue)
                
            }
            .frame(minHeight: GlobalDimension.minDocumentContentHeight)
            .background(ColorPalette.darkBG1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
