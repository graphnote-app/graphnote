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
fileprivate let textSpacing: Double = 14.0
fileprivate let toolbarHeight: CGFloat = 50

struct DocumentView: View {
    @Environment(\.colorScheme) var colorScheme
    let selected: (workspaceId: String, documentId: String)
    
    var open: Binding<Bool>
    
    func toolbar(size: CGSize, open: Binding<Bool>) -> some View {
        ToolbarView(size: size, open: open)
            .frame(height: toolbarHeight)
    }
    
    func documentBody(size: CGSize) -> some View {
        VStack {
            #if os(macOS)
            self.toolbar(size: size, open: open)
            #endif
            ScrollView(showsIndicators: true) {
                #if os(macOS)

                VStack(alignment: .leading, spacing: pad) {
                    HStack {
                        Text("Workspace ID: \(selected.workspaceId) Document ID: \(selected.documentId)")
                            .padding(pad)
                            .foregroundColor(.primary)
                        Spacer()
                    }.frame(width: maxBlockWidth)
                    HStack {
                        Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                            .font(.body)
                            .lineSpacing(textSpacing)
                            .padding(pad)
                            .foregroundColor(.primary)
                        Spacer()
                    }.frame(width: maxBlockWidth)
                    Spacer()
                }
                .frame(minWidth: size.width - scrollWidth, minHeight: size.height * pageMinHeightMultiplier)
                .background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
                #else
                VStack(alignment: .leading, spacing: pad) {
                    HStack {
                        Text("Workspace ID: \(selected.workspaceId) Document ID: \(selected.documentId)")
                            .padding(open.wrappedValue ? pad / 2 : pad)
                            .padding(open.wrappedValue ? [.top, .bottom] : [], pad)
                            .foregroundColor(.primary)
                    }
                    HStack {
                        Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                            .font(.body)
                            .lineSpacing(textSpacing)
                            .padding(open.wrappedValue ? pad / 2 : pad)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    Spacer(minLength: pad * 2)
                }
                .frame(minWidth: size.width, minHeight: size.height * pageMinHeightMultiplier)
                .background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
                #endif
            }.background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
            #if os(iOS)
            self.toolbar(size: size, open: open)
            #endif
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            #if os(macOS)
            VStack {
                documentBody(size: geometry.size)
            }
            .edgesIgnoringSafeArea([.top])
            .background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
            #else
            VStack {
                documentBody(size: geometry.size)
            }
            .background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
            .edgesIgnoringSafeArea(.trailing)
            #endif
        }.background(colorScheme == .dark ? darkBackgroundColor : lightBackgroundColor)
            
    }
}
