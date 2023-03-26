//
//  DocumentView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

fileprivate let pad: Double = 40

struct DocumentView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var blocks: [BlockEntity] = []
    
    @Binding var title: String
    @Binding var labels: [Label]
    
    private func contentFlex(v: some View) -> some View {
        HStack {
            Spacer()
            v.frame(minWidth: GlobalDimension.minDocumentContentWidth)
             .frame(maxWidth: GlobalDimension.maxDocumentContentWidth)
            Spacer()
        }
        .padding([.top, .bottom])
    }
    
    var body: some View {
        ScrollView {
        contentFlex(v:
            Group {
                VStack(alignment: .center, spacing: pad) {
                    HStack() {
                        VStack(alignment: .leading) {
                            TextField("", text: $title)
                                .font(.largeTitle)
                                .textFieldStyle(.plain)
                            Spacer()
                                .frame(height: 20)
                            LabelField(labels: $labels)
                        }
                        .foregroundColor(.primary)
                    }
                    HStack() {
                        BlockView(blocks: blocks) {
                            print("hello")
                            
                        }
                            
                        Spacer()
                    }
                    Spacer()
                }
                
            }
            .padding(.trailing, GlobalDimension.toolbarWidth)
            .padding(GlobalDimension.toolbarWidth + Spacing.spacing1.rawValue))
        }
        .frame(minHeight: GlobalDimension.minDocumentContentHeight)
        .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(title: .constant("Test"), labels: .constant([]))
    }
}
