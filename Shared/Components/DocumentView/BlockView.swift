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
    @Binding var focused: UUID?
    @Binding var selectedLink: UUID?
    @Binding var selectedIndex: Int?
    let onEnter: (_ id: UUID) -> Void
    let focusChanged: (_ isFocused: Bool) -> Void
    
    @StateObject private var vm: BlockViewVM
    
    init(user: User,
        workspace: Workspace,
        document: Document,
        block: Block,
        promptText: Binding<String>,
        editable: Bool,
        focused: Binding<UUID?>,
        selectedLink: Binding<UUID?>,
        selectedIndex: Binding<Int?>,
        onEnter: @escaping (UUID) -> Void,
        focusChanged: @escaping (Bool) -> Void
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
        self.onEnter = onEnter
        self.focusChanged = focusChanged
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
       Group {
           switch BlockType(rawValue: block.type.rawValue) {
           case .contentLink:
               if let id = UUID(uuidString: block.content), let text = vm.getBlockText(id: id) {
                   BodyView(id: id, text: text, focused: .constant(nil)) { _ in
                       
                   } focusChanged: { isFocused in
                   }
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
               }
           case .body:
               BodyView(id: block.id, text: vm.content, editable: editable, focused: $focused, onPromptEnter: onEnter) { newValue in
                   vm.content = newValue
                   print("Update block: \(block.id) with newValue: \(newValue)")
               } focusChanged: { isFocused in
                   focusChanged(isFocused)
               }
               .padding([.top, .bottom], Spacing.spacing2.rawValue)
               .onSubmit {
                   if vm.content.isEmpty {
//                        onEmptyEnter(block.order)
                   }
               }
               .id(block.id)
               .onTapGesture {
                   selectedLink = block.id
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
//           case .empty:
//               EmptyBlockView(id: block.id, focused: block.document.focused) {
//                   onEmptyClick(block.id)
//               }
//               .padding([.top, .bottom], Spacing.spacing2.rawValue)

           case .bullet:
               BulletView(text: block.content)
                   .padding([.top, .bottom], Spacing.spacing2.rawValue)
//           case .prompt:
//               HStack {
//                   if focusFieldPromptFlag {
//                       PromptField(placeholder: "Press '/'", text: $promptText) {
//                           onPromptEnter(block.id)
//                           promptText = ""
//                       }
//                       .focused($focusedField, equals: .prompt)
//                       .padding([.top, .bottom], Spacing.spacing2.rawValue)
//
//                   }
//               }
//               .onAppear {
//                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.125) {
//                       focusedField = .prompt
//                       focusFieldPromptFlag = true
//                   }
//               }
           case .none:
               EmptyView()
           default:
               EmptyView()
           }
       }
       .onReceive(NotificationCenter.default.publisher(for: blockUpdatedNotification)) { notification in
           vm.fetch()
       }
       .onReceive(NotificationCenter.default.publisher(for: blockCreatedNotification)) { notification in
           vm.fetch()
       }
       .id("\(block.content)")
    }
}
