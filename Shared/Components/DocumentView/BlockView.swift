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
    let editable: Bool
    @Binding var selectedLink: UUID?
    @Binding var selectedIndex: Int?
    let onPromptEnter: (_ index: Int) -> Void
    let onEmptyEnter: (_ index: Int) -> Void
    let onEmptyClick: (Int) -> Void
    
    @StateObject private var vm: BlockViewVM
    
    init(user: User,
        workspace: Workspace,
        document: Document,
        block: Block,
        promptText: Binding<String>,
        editable: Bool,
        selectedLink: Binding<UUID?>,
        selectedIndex: Binding<Int?>,
        onPromptEnter: @escaping (Int) -> Void,
        onEmptyEnter: @escaping (Int) -> Void,
        onEmptyClick: @escaping (Int) -> Void
    ) {
        self.user = user
        self.workspace = workspace
        self.document = document
        self.block = block
        self._promptText = promptText
        self.editable = editable
        self._selectedLink = selectedLink
        self._selectedIndex = selectedIndex
        self.onPromptEnter = onPromptEnter
        self.onEmptyEnter = onEmptyEnter
        self.onEmptyClick = onEmptyClick
        self._vm = StateObject(wrappedValue: BlockViewVM(text: block.content, user: user, workspace: workspace, document: document, block: block))
    }
    
    private let blockUpdatedNotification = Notification.Name(SyncServiceNotification.blockUpdated.rawValue)
    private let blockCreatedNotification = Notification.Name(SyncServiceNotification.blockCreated.rawValue)
    
    enum FocusedField {
        case prompt
    }
    
    @FocusState private var focusedField: FocusedField?
    @FocusState private var isFocused: Bool
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
            case .contentLink:
                BodyView(text: vm.getBlockText(id: UUID(uuidString: block.content)!), textDidChange: { _ in
                })
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.accentColor)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.accentColor.opacity(0.05))
                    }
                    .padding(-12)
                }
                .padding([.leading, .trailing], 12)
                .padding([.top, .bottom], 24)
            case .body:
                BodyView(text: vm.content, editable: editable) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
                .padding([.top, .bottom], Spacing.spacing2.rawValue)
                .onSubmit {
                    onEmptyEnter(block.order)
                }
                .onTapGesture {
                    selectedLink = block.id
                    selectedIndex = block.order
                }
                .overlay {
                    if let selectedLink {
                        if selectedLink == block.id {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor)
                                
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.accentColor.opacity(0.05))
                            }
                            .padding(-8)
                        }
                    }
                }
            case .heading1:
                HeadingView(size: .heading1, text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
                .padding([.top, .bottom], Spacing.spacing2.rawValue)
            case .heading2:
                HeadingView(size: .heading2, text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
                .padding([.top, .bottom], Spacing.spacing2.rawValue)
            case .heading3:
                HeadingView(size: .heading3, text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
                .padding([.top, .bottom], Spacing.spacing2.rawValue)
            case .heading4:
                HeadingView(size: .heading4, text: vm.content) { newValue in
                    vm.content = newValue
                    print("Update block: \(block.id) with newValue: \(newValue)")
                }
                .padding([.top, .bottom], Spacing.spacing2.rawValue)
            case .empty:
                EmptyBlockView {
                    onEmptyClick(block.order)
                }
                .padding([.top, .bottom], Spacing.spacing2.rawValue)
            case .bullet:
                BulletView(text: block.content)
                    .padding([.top, .bottom], Spacing.spacing2.rawValue)
            case .prompt:
                PromptField(placeholder: "Press '/'", text: $promptText) {
                    promptText = ""
                }
                .padding([.top, .bottom], Spacing.spacing2.rawValue)
                .onSubmit {
                    onPromptEnter(block.order + 1)
                }
                .onAppear {
                    isFocused = true
                }
                .focused($focusedField, equals: .prompt)
            case .none:
                EmptyView()
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
        .onReceive(NotificationCenter.default.publisher(for: blockUpdatedNotification)) { notification in
            vm.fetch()
        }
        .onReceive(NotificationCenter.default.publisher(for: blockCreatedNotification)) { notification in
            vm.fetch()
        }
        .id("\(block.content):\(block.order)")
    }
}
