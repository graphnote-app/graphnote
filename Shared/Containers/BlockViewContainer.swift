//
//  BlockViewContainer.swift
//  Graphnote
//
//  Created by Hayden Pennington on 4/17/23.
//

import SwiftUI

struct FocusedPrompt {
    let uuid: UUID?
    let text: String
}

struct BlockViewContainer: View {
    let user: User
    let workspace: Workspace
    let document: Document
    let blocks: [Block]
    @Binding var promptMenuOpen: Bool
    let editable: Bool
    @Binding var selectedLink: UUID?
    @Binding var focused: FocusedPrompt
    let action: () -> Void
    
    @StateObject private var vm = BlockViewContainerVM()
    @State private var isKeyDown = false
    @State private var id: UUID? = nil
    @State private var prevContent = "INIT"
    
    private let blockCreatedNotification = Notification.Name(DataServiceNotification.blockCreated.rawValue)
    private let blockDeletedNotification = Notification.Name(DataServiceNotification.blockDeleted.rawValue)
    private let blockUpdatedNotification = Notification.Name(SyncServiceNotification.blockUpdated.rawValue)
    private let blockDeletedSyncServiceNotification = Notification.Name(SyncServiceNotification.blockDeleted.rawValue)
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ForEach(blocks, id: \.id) { block in
                if block.graveyard  {
                    EmptyView()
                        .frame(width: .zero, height: .zero)
                        .id(id)
                } else {
                    BlockView(user: user,
                              workspace: workspace,
                              document: document,
                              block: block,
                              editable: block.type == .contentLink ? false : editable,
                              focused: $focused,
                              selectedLink: $selectedLink,
                              promptMenuOpen: $promptMenuOpen,
                              selectedContentId: $selectedLink,
                              fetch: action
                    ) { (id, text) in
                        
                        guard let index = blocks.firstIndex(where: { $0.id == id }) else {
                            return
                        }
                        
                        if index == 0 && blocks.isEmpty {
                            if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: "", prev: block.id, next: nil) {
                                vm.updateBlock(block, user: user, workspace: workspace,  document: document, next: newBlock.id, text: text)
                                DataService.shared.updateDocumentFocused(user: user, workspace: workspace, document: document, focused: newBlock.id)
                                focused = FocusedPrompt(uuid: newBlock.id, text: newBlock.content)
                                
                            }
                        } else {
                            if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: "", prev: block.id, next: block.next) {
                                vm.updateBlock(block, user: user, workspace: workspace,  document: document, next: newBlock.id, text: text)
                                DataService.shared.updateDocumentFocused(user: user, workspace: workspace, document: document, focused: newBlock.id)
                                focused = FocusedPrompt(uuid: newBlock.id, text: newBlock.content)
                            }
                        }
                        
                        action()
                    }
                    .id(block.id)
                }
            }
        }
        .onAppear {
            focused = FocusedPrompt(uuid: document.focused, text: "")
        }
        .onReceive(NotificationCenter.default.publisher(for: blockCreatedNotification)) { notification in
            action()
        }
        .onReceive(NotificationCenter.default.publisher(for: blockDeletedNotification)) { notification in
            action()
        }
        .onReceive(NotificationCenter.default.publisher(for: blockUpdatedNotification)) { notification in
            action()
        }
        .onReceive(NotificationCenter.default.publisher(for: blockDeletedSyncServiceNotification)) { notification in
            action()
        }
        .fixedSize(horizontal: false, vertical: true)
        .submitScope()
    }
}
