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
    @Binding var promptText: String
    let action: () -> Void
    
    @StateObject private var vm = BlockViewContainerVM()
    @State private var isKeyDown = false
    @State private var id: UUID? = nil
    @State private var prevContent = "INIT"
    
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
                BlockView(user: user, workspace: workspace, document: document, block: block, promptText: $promptText, editable: editable, selectedLink: $selectedLink, selectedIndex: $selectedIndex) { id in
                    if let index = blocks.firstIndex { block in
                        block.id == id
                    } {
                        do {
                            // block == prompt
                            #if DEBUG
                            assert(block.type == .prompt)
                            #endif
                            
                            // If first block insert at zero if not first block insert at index of prompt - 1
                            
                            guard let index = blocks.firstIndex(where: { block in
                                block.id == id
                            }) else {
                                return
                            }
                            
                            if index == 0 {
                                if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText, prev: nil, next: block.id) {
                                    vm.updateBlock(block, user: user, workspace: workspace, document: document, prev: newBlock.id)
                                }
                            } else {
                                if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText, prev: block.prev, next: block.id) {
                                    vm.updateBlock(block, user: user, workspace: workspace, document: document, prev: newBlock.id)
                                    vm.updateBlock(blocks[index - 1], user: user, workspace: workspace, document: document, next: newBlock.id)
                                }
                            }
                            
                            
                            
//                            let documentRepo = DocumentRepo(user: user, workspace: workspace)
//
//                            if let prev = block.prev, let lastBlock = try documentRepo.readBlock(document: document, block: prev) {
//                                if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText, prev: lastBlock.prev, next: lastBlock.id) {
//                                    vm.updateBlock(lastBlock, user: user, workspace: workspace, document: document, prev: newBlock.id)
//                                }
//                            } else {
//                                if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText, prev: block.prev, next: block.id) {
//                                    vm.updateBlock(block, user: user, workspace: workspace, document: document, prev: newBlock.id)
//                                }
//                            }
//
                            action()
                        } catch let error {
                            print(error)
                        }
                    }
                } onEmptyEnter: { index in
                    // - TODO: BLOCK PREV NEXT
//                    if let emptyBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText) {
//                        vm.movePromptToEmptySpace(user: user, workspace: workspace, document: document, block: emptyBlock)
//                        action()
//                    }
                    
                } onEmptyClick: { index in
                    vm.movePromptToEmptySpace(user: user, workspace: workspace, document: document, block: block)
                    action()
                }
                .onAppear {
                    if block.type == .prompt {
                        id = block.id
                    }
                }
                .id(block.id)

            }
            
        }
        .onAppear {
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
