//
//  DocumentView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/23/22.
//

import SwiftUI
import Combine
import CoreData

fileprivate let scrollWidth: CGFloat = 16
fileprivate let pageMinHeightMultiplier = 1.3
fileprivate let maxBlockWidth: CGFloat = 800
fileprivate let pad: Double = 40
fileprivate let textSpacing: Double = 14.0
fileprivate let toolbarHeight: CGFloat = 28

struct DocumentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    var open: Binding<Bool>
    
    let documentId: UUID
    let workspaceId: UUID
    
    @ObservedObject private var viewModel: DocumentViewViewModel
    
    @State private var blocks: [Block] = []
    
    init(moc: NSManagedObjectContext, id: UUID, workspaceId: UUID, open: Binding<Bool>) {
        self.documentId = id
        self.workspaceId = workspaceId
        self.open = open

        self.viewModel = DocumentViewViewModel(id: documentId, workspaceId: workspaceId, moc: moc)
    }
    
    func toolbar(open: Binding<Bool>) -> some View {
        ToolbarView(open: open)
            .frame(height: toolbarHeight)
    }
    
    func documentBody(size: CGSize) -> some View {
        ZStack {
            #if os(macOS)
            NavigationButtonView()
                .frame(width: 100, height: 100)
                .zIndex(100)
                .position(x: 24, y: size.height)
                .onTapGesture {
                    open.wrappedValue = !open.wrappedValue
                }
            #endif
            VStack {
                ScrollView(showsIndicators: true) {
                    #if os(macOS)

                    VStack(alignment: .center, spacing: pad) {
                        HStack() {
                            VStack(alignment: .leading) {
                                TextField("", text: $viewModel.title)
                                    .font(.largeTitle)
                                    .textFieldStyle(.plain)
                                Spacer()
                                    .frame(height: 20)
                                TextField("", text: $viewModel.workspaceTitle)
                                    .font(.headline)
                                    .textFieldStyle(.plain)
                            }
//                                .padding(open.wrappedValue ? .leading : [.leading, .trailing, .top], pad)
                                .padding(open.wrappedValue ? .top : [], pad)
                                .foregroundColor(.primary)
                        }.frame(width: maxBlockWidth)
                        HStack() {
                            BlockView(blocks: blocks)
                                .onSubmit {
                                    print("Add new block to memory")
                                }
//                                .padding([.leading, .trailing], pad)
                            Spacer()
                        }.frame(width: maxBlockWidth)
                        HStack {
//                            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                            Text("")
                                .font(.body)
                                .lineSpacing(textSpacing)
                                .padding(pad)
                                .foregroundColor(.primary)
                            Spacer()
                        }.frame(width: maxBlockWidth)
                        Spacer()
                    }
                    .frame(minWidth: size.width - scrollWidth, minHeight: size.height * pageMinHeightMultiplier)
                    .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
                    #else
                    VStack(alignment: .leading, spacing: pad) {
                        HStack {
                            VStack(alignment: .leading) {
                                TextField("", text: $viewModel.title)
                                    .font(.largeTitle)
                                    .textFieldStyle(.plain)
                                Spacer()
                                    .frame(height: 20)
                                TextField("", text: $viewModel.workspaceTitle)
                                    .font(.headline)
                                    .textFieldStyle(.plain)
                            }
//                            .padding(open.wrappedValue ? .leading : [.leading, .trailing, .top], open.wrappedValue ? pad / 2 : pad)
//                            .padding(open.wrappedValue ? [.top, .bottom] : [], pad)
                                .foregroundColor(.primary)
                            
                        }
                        HStack() {
                            BlockView()
//                                .padding([.leading, .trailing], pad)
                            Spacer()
                        }
                        HStack {
                            Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
                                .font(.body)
                                .lineSpacing(textSpacing)
//                                .padding(open.wrappedValue ? pad / 2 : pad)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        Spacer(minLength: pad * 2)
                    }
                    .padding(.leading, pad / 2)
                    .padding(.trailing, pad)
                    .frame(minWidth: size.width, minHeight: size.height * pageMinHeightMultiplier)
                    .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
                    .padding(.top, pad * 2)
                    #endif
                    
                }
                .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
                .padding(Spacing.spacing6.rawValue)
                .edgesIgnoringSafeArea(.top)
                #if os(iOS)
                self.toolbar(open: open)
                #endif
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            #if os(macOS)
            VStack {
                documentBody(size: geometry.size)
            }
            .edgesIgnoringSafeArea([.top])
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
            #else
            VStack {
                documentBody(size: geometry.size)
            }
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
            .edgesIgnoringSafeArea(.trailing)
            #endif
        }
        .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
        .onAppear {
            let fetchedBlocks = viewModel.fetchBlocks(workspaceId: workspaceId, documentId: documentId)
            if let fetchedBlocks {
                self.blocks = fetchedBlocks
            }
        }
    }
}
