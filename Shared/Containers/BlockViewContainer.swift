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
    @Binding var selectedIndex: Int?
    @Binding var promptText: String
    let action: () -> Void
    
    @StateObject private var vm = BlockViewContainerVM()
    @State private var isKeyDown = false
    @State private var id: UUID? = nil
    @State private var prevContent = "INIT"
    @State private var focused: FocusedPrompt = FocusedPrompt(uuid: nil, text: "")
    
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
                            focused = FocusedPrompt(uuid: newBlock.id, text: newBlock.content)
                            
                        }
                    } else {
                        if let newBlock = vm.insertBlock(user: user, workspace: workspace, document: document, promptText: promptText, prev: block.id, next: block.next) {
                            vm.updateBlock(block, user: user, workspace: workspace,  document: document, next: newBlock.id)
                            DataService.shared.updateDocumentFocused(user: user, workspace: workspace, document: document, focused: newBlock.id)
                            focused = FocusedPrompt(uuid: newBlock.id, text: newBlock.content)
                        }
                    }
                    
                    action()
                }
                .id(block.id)
            }
        }
        .onAppear {
            focused = FocusedPrompt(uuid: document.focused, text: "")
            
            if focused.uuid != nil {
                if let content = blocks.first(where: {$0.id == focused.uuid})?.content {
                    promptText = content
                }
            }
            
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
//        .onChange(of: focused, perform: { newValue in
//            if newValue != nil {
//                if let content = blocks.first(where: {$0.id == focused})?.content {
//                    promptText = content
//                }
//            }
//        })
        .onChange(of: promptText) { newValue in
            if newValue == "/" {
                withAnimation {
                    promptMenuOpen = true
                }
                
            } else if newValue == "" {
                withAnimation {
                    promptMenuOpen = false
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .submitScope()
    }
}
