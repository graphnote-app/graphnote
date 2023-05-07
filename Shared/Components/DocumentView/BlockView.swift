//
//  BlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/23/23.
//

import SwiftUI
enum BlockFocusedField {
    case prompt
    case body
}

struct BlockView: View {
    let user: User
    let workspace: Workspace
    let document: Document
    let block: Block
    @Binding var promptText: String
    let editable: Bool
    @Binding var focused: FocusedPrompt
    @Binding var selectedLink: UUID?
    @Binding var selectedIndex: Int?
    let fetch: () -> Void
    let onEnter: (_ id: UUID) -> Void
    
    @StateObject private var vm: BlockViewVM
    
    init(user: User,
        workspace: Workspace,
        document: Document,
        block: Block,
        promptText: Binding<String>,
        editable: Bool,
        focused: Binding<FocusedPrompt>,
        selectedLink: Binding<UUID?>,
        selectedIndex: Binding<Int?>,
        fetch: @escaping () -> Void,
        onEnter: @escaping (UUID) -> Void
    ) {
        self.user = user
        self.workspace = workspace
        self.document = document
        self.block = block
        self._promptText = promptText
        self.editable = editable
        self._focused = focused
        self._selectedLink = selectedLink
        self._selectedIndex = selectedIndex
        self.fetch = fetch
        self.onEnter = onEnter
        
        self._vm = StateObject(wrappedValue: BlockViewVM(text: block.content, user: user, workspace: workspace, document: document, block: block))
    }
    
    private let blockUpdatedNotification = Notification.Name(SyncServiceNotification.blockUpdated.rawValue)
    private let blockCreatedNotification = Notification.Name(SyncServiceNotification.blockCreated.rawValue)
    
    @FocusState private var focusedField: BlockFocusedField? {
        didSet {
            focusFieldPromptFlag = focusedField == .prompt ? true : false
        }
    }
    @State private var focusFieldPromptFlag = false
    
    var body: some View {
        PromptField(id: block.id, type: .body, block: block, focused: $focused) {
            self.onEnter(block.id)
        } onBackspaceRemove: {
            do {
                
                if let prev = block.prev {
                    if let prevBlock = vm.readBlock(id: prev, user: user, workspace: workspace) {
                        self.focused = FocusedPrompt(uuid: prevBlock.id, text: prevBlock.content)
                    }
                    
                } else if let next = block.next {
                    if let nextBlock = vm.readBlock(id: next, user: user, workspace: workspace) {
                        self.focused = FocusedPrompt(uuid: nextBlock.id, text: nextBlock.content)
                    }
                }
                
                try vm.deleteBlock(block: block, user: user, workspace: workspace)
                fetch()
                
            } catch let error {
                print(error)
            }
        }
        .onChange(of: focused.uuid, perform: { newValue in
            if newValue == block.id {
                promptText = block.content
            }
        })
        .id(block.id)
    }
}
