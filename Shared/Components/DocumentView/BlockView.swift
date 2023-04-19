//
//  BlockView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/23/23.
//

import SwiftUI

struct BlockView: View {
    let user: User
    let workspace: Workspace
    let document: Document
    let block: Block
    @Binding var promptText: String
    let onEnter: (() -> Void)
    let save: (() -> Void)
    
    @StateObject private var vm: BlockViewVM
    
    init(user: User, workspace: Workspace, document: Document, block: Block, promptText: Binding<String>, onEnter: @escaping () -> Void, save: @escaping () -> Void) {
        self.user = user
        self.workspace = workspace
        self.document = document
        self.block = block
        self._promptText = promptText
        self.onEnter = onEnter
        self.save = save
        self._vm = StateObject(wrappedValue: BlockViewVM(text: block.content, user: user, workspace: workspace, document: document, block: block))
    }
    
    private let blockUpdatedNotification = Notification.Name(SyncServiceNotification.blockUpdated.rawValue)
    private let blockCreatedNotification = Notification.Name(SyncServiceNotification.blockCreated.rawValue)
    
    @FocusState var isFocused: Bool
    @State private var prevContent = "INIT"
    @State private var isKeyDown = false
    
    #if os(macOS)
    private func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!) {
            if self.isKeyDown == false {
                self.isKeyDown = true
                if vm.content == "" {
                    vm.deleteBlock(id: block.id)
                }
                prevContent = vm.content
            }
        }
    }
    #endif
    
    var body: some View {
        Group {
            switch BlockType(rawValue: block.type.rawValue) {
            case .body:
                BodyView(text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
            case .heading1:
                HeadingView(size: .heading1, text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
            case .heading2:
                HeadingView(size: .heading2, text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
            case .heading3:
                HeadingView(size: .heading3, text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
            case .heading4:
                HeadingView(size: .heading4, text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
            case .empty:
                EmptyBlockView()
            case .bullet:
                BulletView(text: block.content)
            case .prompt:
                PromptField(placeholder: "Press '/'", text: $promptText) {
//                    vm.appendBlock(user: user, workspace: workspace, document: document, text: promptText)
                    promptText = ""
//                    fetchBlocks()
                    save()
                }
            case .none:
                EmptyView()
            }
        }
        .onSubmit {
            onEnter()
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
        .onReceive(NotificationCenter.default.publisher(for: blockUpdatedNotification)) { notification in
            vm.fetch()
        }
        .onReceive(NotificationCenter.default.publisher(for: blockCreatedNotification)) { notification in
            vm.fetch()
        }
        .id("\(block.content):\(block.order)")
        BlockSpacer()
    }
}
