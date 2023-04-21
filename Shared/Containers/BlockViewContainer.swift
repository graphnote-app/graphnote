//
//  BlockViewContainer.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

struct BlockViewContainer: View {
    let user: User
    let workspace: Workspace
    let document: Document
    @Binding var blocks: [Block]
    let action: () -> Void
    
    @StateObject private var vm = BlockViewContainerVM()
    @State private var promptText = ""

    private let blockCreatedNotification = Notification.Name(DataServiceNotification.blockCreated.rawValue)
    private let blockUpdatedNotification = Notification.Name(SyncServiceNotification.blockUpdated.rawValue)
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ForEach(blocks.sorted(by: { a, b in
                a.order < b.order
            }), id: \.id) { block in
                BlockView(user: user, workspace: workspace, document: document, block: block, promptText: $promptText) {
                    vm.insertBlock(index: block.type == .prompt ? block.order - 1 : block.order, user: user, workspace: workspace, document: document, promptText: promptText)
                    action()
                } save: {
//                    vm.insertBlock(index: block.order, user: user, workspace: workspace, document: document, promptText: promptText)
//                    action()
                } onEmptyClick: { index in
                    vm.movePromptToEmptySpace(index: index, user: user, workspace: workspace, document: document, block: block)
                    action()
                }
                .id(block.id)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: blockCreatedNotification)) { notification in
            action()
        }
        .onReceive(NotificationCenter.default.publisher(for: blockUpdatedNotification)) { notification in
            action()
        }

        .fixedSize(horizontal: false, vertical: true)
        .submitScope()
    }
}

//struct BlockViewContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        BlockViewContainer()
//    }
//}
