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
    let user: User
    let workspace: Workspace
    let document: Document
    let fetch: () -> Void
    let onRefresh: () -> Void
    
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
                        LabelField(fetch: fetch, labels: $labels, user: user, workspace: workspace, document: document)
                    }
                    .foregroundColor(.primary)
                }
                HStack() {
                    BlockViewContainer(user: user, workspace: workspace, document: document, blocks: blocks)
                    
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
                    .padding(.top, Spacing.spacing8.rawValue)
                #endif
            }
            .frame(minHeight: GlobalDimension.minDocumentContentHeight)
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
        }
        .refreshable {
            onRefresh()
        }
    }
}

