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
    let onRefresh: () -> Void
    
    @StateObject private var vm = DocumentContainerVM()
    
    private let labelLinkCreatedNotification = Notification.Name(SyncServiceNotification.labelLinkCreated.rawValue)

    init(user: User, workspace: Workspace, document: Document, onRefresh: @escaping () -> Void) {
        self.user = user
        self.workspace = workspace
        self.document = document
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        DocumentView(title: $vm.title, labels: $vm.labels, blocks: $vm.blocks, user: user, workspace: workspace, document: document) {
            vm.fetch(user: user, workspace: workspace, document: document)
        } fetchBlocks: {
            vm.fetchBlocks(user: user, workspace: workspace, document: document)
        } onRefresh: {
            vm.fetch(user: user, workspace: workspace, document: document)
        }
        .id(document.id)
        .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
        .onAppear {
            vm.fetch(user: user, workspace: workspace, document: document)
        }
        .onReceive(NotificationCenter.default.publisher(for: labelLinkCreatedNotification)) { notification in
            vm.fetch(user: user, workspace: workspace, document: document)
        }
        .onChange(of: document) { _ in
            vm.fetch(user: user, workspace: workspace, document: document)
        }
        .onDisappear {
            vm.save()
        }
    }
}
