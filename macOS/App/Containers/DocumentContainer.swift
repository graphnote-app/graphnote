//
//  DocumentContainer.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/29/23.
//

import SwiftUI

struct DocumentContainer: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let user: User
    let workspace: Workspace
    let document: Document
    
    @StateObject private var vm = DocumentContainerVM()
    
    var body: some View {
        DocumentView(title: $vm.title, labels: $vm.labels, blocks: $vm.blocks)
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
            .onAppear {
                vm.fetch(user: user, workspace: workspace, document: document)
            }
            .onChange(of: document) { _ in
                vm.fetch(user: user, workspace: workspace, document: document)
            }
    }
}
