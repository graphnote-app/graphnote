//
//  DocumentView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

fileprivate let pad: Double = 30

struct DocumentView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var title: String
    @Binding var labels: [Label]
    @Binding var blocks: [Block]
    
    var content: some View {
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
    }

    var body: some View {
        ScrollView {
            HorizontalFlexView {
                #if os(macOS)
                content
                    .padding(GlobalDimension.toolbarWidth + Spacing.spacing1.rawValue)
                #else
                content
                #endif
            }
            .frame(minHeight: GlobalDimension.minDocumentContentHeight)
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
        }
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(title: .constant("Test"), labels: .constant([]), blocks: .constant([]))
    }
}
