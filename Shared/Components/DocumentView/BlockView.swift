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
    let editable: Bool
    @Binding var focused: FocusedPrompt
    @Binding var selectedLink: UUID?
    @Binding var promptMenuOpen: Bool
    @Binding var selectedContentId: UUID?
    let fetch: () -> Void
    let onEnter: (_ id: UUID, _ text: String) -> Void
    
    @StateObject private var vm: BlockViewVM
    
    init(user: User,
        workspace: Workspace,
        document: Document,
        block: Block,
        editable: Bool,
        focused: Binding<FocusedPrompt>,
        selectedLink: Binding<UUID?>,
        promptMenuOpen: Binding<Bool>,
        selectedContentId: Binding<UUID?>,
        fetch: @escaping () -> Void,
        onEnter: @escaping (UUID, String) -> Void
    ) {
        self.user = user
        self.workspace = workspace
        self.document = document
        self.block = block
        self.editable = editable
        self._focused = focused
        self._selectedLink = selectedLink
        self._promptMenuOpen = promptMenuOpen
        self._selectedContentId = selectedContentId
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
    @State private var linkContent: String = ""
    
    @ViewBuilder var bodyType: some View {
        if editable {
            PromptField(id: block.id, type: .body, block: block, focused: $focused, promptMenuOpen: $promptMenuOpen) { (id, text) in
                self.onEnter(id, text)
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
            .id(block.id)
        } else {
            if block.id == selectedContentId  {
                PromptView(id: block.id, type: block.type, block: block)
                    .border(LabelPalette.primary.getColor(), width: 2)
                    .onTapGesture {
                        if block.id != selectedContentId {
                            selectedContentId = block.id
                        } else {
                            selectedContentId = nil
                        }
                    }
            } else {
                PromptView(id: block.id, type: block.type, block: block)
                    .onTapGesture {
                        if block.id != selectedContentId {
                            selectedContentId = block.id
                        } else {
                            selectedContentId = nil
                        }
                    }
            }
        }
    }
    
    var contentLinkType: some View {
        Text(linkContent)
            .border(LabelPalette.primary.getColor(), width: 2)
            .onAppear {
                if let content = vm.readBlock(id: UUID(uuidString: block.content)!, user: user, workspace: workspace)?.content {
                    linkContent = content
                }
            }
    }
    
    var body: some View {
        switch block.type {
        case .body, .heading1, .heading2, .heading3, .heading4:
            bodyType
        case .contentLink:
            contentLinkType
        default:
            fatalError()
        }
    }
}
