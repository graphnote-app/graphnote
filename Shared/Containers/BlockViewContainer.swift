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
    @Binding var promptMenuOpen: Bool
    let editable: Bool
    @Binding var selectedLink: UUID?
    @Binding var selectedIndex: Int?
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
                BlockView(user: user, workspace: workspace, document: document, block: block, promptText: $promptText, editable: editable, selectedLink: $selectedLink, selectedIndex: $selectedIndex) { index in
                    vm.insertBlock(index: block.order, user: user, workspace: workspace, document: document, promptText: promptText)
                    action()
                } onEmptyEnter: { index in
                    if let emptyBlock = vm.insertBlock(index: block.order + 1, user: user, workspace: workspace, document: document, promptText: promptText) {
                        vm.movePromptToEmptySpace(index: emptyBlock.order, user: user, workspace: workspace, document: document, block: emptyBlock)
                        action()
                    }
                    
                } onEmptyClick: { index in
                    vm.insertBlock(index: index, user: user, workspace: workspace, document: document, promptText: promptText)
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
        .onChange(of: promptText) { newValue in
            if newValue == "/" {
                promptMenuOpen = true
            } else if newValue == "" {
                promptMenuOpen = false
            }
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
