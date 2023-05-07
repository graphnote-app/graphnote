//
//  DocumentView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

///
/// The main document editor for the application.
///
/// # Overview
/// This component is responsible for viewing and editing documents, and everything that comes with docs.
///
/// Use the DocumentView as such:
///
/// ```swift
///     DocumentView(
///         title: $vm.title,
///         labels: $vm.labels,
///         blocks: $vm.blocks,
///         user: $vm.user,
///         workspace: $vm.workspace,
///         document: $vm.document
///     ) {
///
///     } fetchBlocks: {
///
///     } onRefresh: {
///
///     }
/// ```
///
struct DocumentView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    /// A binding to the title label
    @Binding var title: String
    /// The binding to an array of label model objects.
    let labels: [Label]
    /// All labels for suggestions
    let allLabels: [Label]
    /// The binding to an array of block model objects.
    let blocks: [Block]
    /// The logged in user.
    let user: User
    /// The current selected workspace.
    let workspace: Workspace
    /// The current selected document within the workspace.
    let document: Document
    /// The fetch method is called whenver the entire document contents need updating.
    let fetch: () -> Void
    /// This method is for when only the blocks within the documnet need updating (no title, etc).
    let fetchBlocks: () -> Void
    /// Called when "pull to refresh" is invoked to refresh the whole documnet.
    let onRefresh: () -> Void
    /// Call to save the document state (title, etc) whenever the focused state becomes false on title.
    let save: (String) -> Void
    
    @StateObject private var vm = DocumentViewVM()
    @FocusState private var isFocused: Bool
    @State private var focused: FocusedPrompt = FocusedPrompt(uuid: nil, text: "")
    @State private var promptMenuOpen = false
    @State private var linkMenuOpen = false
    @State private var selectedLink: UUID? = nil
    @State private var selectedIndex: Int? = nil
    
    private let pad: Double = 30
    
    var content: some View {
        Group {
            LinkedListView(nodes: blocks.map {
                return NodeView(id: $0.id, type: $0.type.rawValue, content: $0.content, prev: $0.prev, next: $0.next)
            })
            VStack(alignment: .center, spacing: pad) {
                HStack() {
                    VStack(alignment: .leading) {
                        TextField("", text: $title)
                            .font(.largeTitle)
                            .textFieldStyle(.plain)
                            .focused($isFocused)
                            .onChange(of: isFocused) { [title] newValue in
                                if newValue == false {
                                    save(title)
//                                    self.title = title
                                }
                            }
                            .onSubmit {
                                focused = FocusedPrompt(uuid: blocks.first?.id, text: blocks.first?.content ?? "")
                                isFocused = false
                            }
                        
                        Spacer()
                            .frame(height: 20)
                        LabelField(fetch: fetch, labels: labels, allLabels: allLabels, user: user, workspace: workspace, document: document)
                    }
                    .foregroundColor(.primary)
                }
                HStack() {
                    BlockViewContainer(user: user, workspace: workspace, document: document, blocks: blocks, promptMenuOpen: $promptMenuOpen, editable: true, selectedLink: .constant(nil), selectedIndex: .constant(nil), focused: $focused) {
                        fetch()
                    }

                    Spacer()
                }
                Spacer()
            }

        }
        .padding(.trailing, GlobalDimension.toolbarWidth)
    }

    var body: some View {
        ScrollView {
            HorizontalFlexView {
                #if os(macOS)
                content
                    .padding(GlobalDimension.toolbarWidth + Spacing.spacing1.rawValue)
                #else
                content
                    .padding(.top, Spacing.spacing8.rawValue)
                #endif
            }
            .frame(minHeight: GlobalDimension.minDocumentContentHeight)
            .background(colorScheme == .dark ? ColorPalette.darkBG1 : ColorPalette.lightBG1)
        }
        .onAppear {
//            vm.fetchDocuments(user: user, workspace: workspace)
            save(title)
            onRefresh()
        }
        .onTapGesture {
            promptMenuOpen = false
            linkMenuOpen = false
        }
        .overlay {
            if promptMenuOpen == true {
                PromptMenu {
                    promptMenuOpen = false
                    linkMenuOpen = true
                }
            } else if linkMenuOpen == true {
                ContentLinkModal(user: user, workspace: workspace, document: document, documents: vm.documents, selectedIndex: $selectedIndex, selectedLink: $selectedLink, open: $linkMenuOpen)
            }
        }
        .onChange(of: linkMenuOpen, perform: { newValue in
            if newValue == false {
//                vm.clearPrompt(user: user, workspace: workspace, document: document)
            }
        })
        .refreshable {
            onRefresh()
        }
    }
}

