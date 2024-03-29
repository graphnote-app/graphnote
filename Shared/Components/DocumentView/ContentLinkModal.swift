//
//  ContentLinkModal.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/23/23.
//

import SwiftUI

struct ContentLinkModal: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let user: User
    let workspace: Workspace
    let document: Document
    let documents: [Document]
    @Binding var selectedLink: UUID?
    @Binding var open: Bool
    let createLink: () -> Void
    
    @State private var _document: Document?
    
    @StateObject private var vm = ContentLinkModalVM()
    
    var body: some View {
        VStack(alignment: .leading) {
            Menu(_document?.title ?? "") {
                ForEach(documents, id: \.id) { document in
                    Button(document.title) {
                        self._document = document
                        vm.fetchDocument(user: user, workspace: workspace, document: document)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding()
            
            List {
                DocumentPreviewView(title: vm.title, labels: vm.labels, blocks: vm.blocks, user: user, workspace: workspace, document: document, selectedLink: $selectedLink)
                    .frame(maxWidth: .infinity)
            }
            .scrollContentBackground(.hidden)
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)

            HStack {
                Button("Cancel") {
                    selectedLink = nil
                    
                    open = false
                }
                Spacer()
                Button("Create link") {
                    if let selectedLink {
//                        vm.createLink(user: user, workspace: workspace, document: document, content: selectedLink, prev: nil, next: nil)
                        createLink()
                        open = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedLink == nil)
            }
            .padding()
        }
        .frame(width: GlobalDimension.modalWidth, height: GlobalDimension.modalHeight)
        .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
        .cornerRadius(8)
        .shadow(radius: 20)
    }
}
