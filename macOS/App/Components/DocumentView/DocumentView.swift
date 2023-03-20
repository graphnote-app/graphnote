//
//  DocumentView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

fileprivate let scrollWidth: CGFloat = 16
fileprivate let pageMinHeightMultiplier = 1.3
fileprivate let maxBlockWidth: CGFloat = 800
fileprivate let pad: Double = 40
fileprivate let textSpacing: Double = 14.0
fileprivate let toolbarHeight: CGFloat = 28

struct DocumentView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var blocks: [Block] = []
    
    @Binding var title: String
    @Binding var labels: [String]
    
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
            Group {
                contentFlex(v: VStack(alignment: .center, spacing: pad) {
                    HStack() {
                        VStack(alignment: .leading) {
                            TextField("", text: $title)
                                .font(.largeTitle)
                                .textFieldStyle(.plain)
                            Spacer()
                                .frame(height: 20)
                            HStack {
                                ForEach(labels, id: \.self) { label in
                                    Text(label)
                                        .font(.headline)
                                        .textFieldStyle(.plain)
                                        .padding([.leading, .trailing], Spacing.spacing4.rawValue)
                                        .padding([.top, .bottom], Spacing.spacing2.rawValue)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.accentColor, lineWidth: 2)
                                                .foregroundColor(.clear)
                                        }
                                }
                            }
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
                })
                
            }
            .padding(.trailing, GlobalDimension.toolbarWidth)
            .padding(GlobalDimension.toolbarWidth + Spacing.spacing1.rawValue)
            
        }.frame(minHeight: GlobalDimension.minDocumentContentHeight)
        .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(title: .constant("Test"), labels: .constant([]))
    }
}
