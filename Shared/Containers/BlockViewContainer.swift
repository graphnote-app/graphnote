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
    let blocks: [Block]
    @Binding var promptMenuOpen: Bool
    let editable: Bool
    @Binding var selectedLink: UUID?
    @Binding var selectedIndex: Int?
    @Binding var promptText: String
    let action: () -> Void
    
    @StateObject private var vm = BlockViewContainerVM()
    @State private var isKeyDown = false
    @State private var id: UUID? = nil
    @State private var prevContent = "INIT"
    @State private var focused: UUID? = nil
    
    private let blockCreatedNotification = Notification.Name(DataServiceNotification.blockCreated.rawValue)
    private let blockDeletedNotification = Notification.Name(DataServiceNotification.blockDeleted.rawValue)
    private let blockUpdatedNotification = Notification.Name(SyncServiceNotification.blockUpdated.rawValue)
    
    #if os(macOS)
    private func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!) {
            if self.isKeyDown == false {
                self.isKeyDown = true
                if promptText == "" {
                    if let id {
                        vm.backspaceOnEmpty(user: user, workspace: workspace, document: document, id: id)
                        action()
                    }
                }
                prevContent = promptText
            }
        }
    }
    #endif
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            // - TODO: Sort!
            ForEach(blocks, id: \.id) { block in
                BlockView(user: user,
                          workspace: workspace,
                          document: document,
                          block: block,
                          promptText: $promptText,
                          editable: editable,
                          focused: $focused,
                          selectedLink: $selectedLink,
                          selectedIndex: $selectedIndex
                ) { id in
                    
                    guard let index = blocks.firstIndex(where: { $0.id == id }) else {
                        return
                    }
                    
                    if index == 0 {
                        if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText, prev: block.id, next: nil) {
                            vm.updateBlock(block, user: user, workspace: workspace,  document: document, next: newBlock.id)
                            DataService.shared.updateDocumentFocused(user: user, workspace: workspace, document: document, focused: newBlock.id)
                            focused = newBlock.id
                            
                        }
                    } else {
                        if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText, prev: block.id, next: block.next) {
                            vm.updateBlock(block, user: user, workspace: workspace,  document: document, next: newBlock.id)
                            DataService.shared.updateDocumentFocused(user: user, workspace: workspace, document: document, focused: newBlock.id)
                            focused = newBlock.id
                        }
                    }
                    
                    action()
                } focusChanged: { isFocused in
                    if isFocused == false {
                        focused = nil
                    }
                }
                .id(block.id)
//            onEmptyEnter: { id in
//
//                    if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText, prev: block.prev, next: block.id) {
//                        vm.updateBlock(block, user: user, workspace: workspace, document: document, prev: newBlock.id)
//                        guard let index = blocks.firstIndex(where: { $0.id == id }) else {
//                            return
//                        }
//
//                        if index - 1 < blocks.count && index - 1 >= 0 {
//                            vm.updateBlock(blocks[index - 1], user: user, workspace: workspace, document: document, next: newBlock.id)
//                        }
//
//                        vm.updateBlock(block, user: user, workspace: workspace, document: document, type: .body)
//                    }

////                    action()
//
//                } onEmptyClick: { id in
////                    guard let index = blocks.firstIndex(where: { $0.type == .body && $0.content.isEmpty}) else {
////                        return
////                    }
////
////                    if index >= 0 && index < blocks.count {
////                        vm.updateBlock(blocks[index], user: user, workspace: workspace, document: document, type: .body)
////                    }
////
////                    vm.updateBlock(block, user: user, workspace: workspace, document: document, type: .body)
////                    action()
//                }
                .onAppear {
                    if block.type == .body {
                        id = block.id
                    }
                }

            }
        }
        .onAppear {
            focused = document.focused
            
            #if os(macOS)
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
                self.isKeyDown = false
                self.keyDown(with: $0)
                return $0
            }
            #endif
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
