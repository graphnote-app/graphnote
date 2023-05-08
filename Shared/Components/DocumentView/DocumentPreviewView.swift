//
//  DocumentPreviewView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 4/23/23.
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
///     )
/// ```
///
struct DocumentPreviewView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    /// A binding to the title label
    let title: String
    /// The binding to an array of label model objects.
    let labels: [Label]
    /// All the labels in the workspace for suggestions.
    let blocks: [Block]
    
    /// The logged in user.
    let user: User
    /// The current selected workspace.
    let workspace: Workspace
    /// The current selected document within the workspace.
    let document: Document
    /// The selected block when creating a content link.
    @Binding var selectedLink: UUID?
    
    @StateObject private var vm = DocumentViewVM()
    @State private var promptMenuOpen = false
    @State private var linkMenuOpen = false
    @State private var focused: FocusedPrompt = FocusedPrompt(uuid: nil, text: "")
    
    private let pad: Double = 30
    
    var content: some View {
        Group {
            VStack(alignment: .leading, spacing: pad) {
//                HStack() {
//                    VStack(alignment: .leading) {
//                        TextField("", text: .constant(title))
//                            .font(.largeTitle)
//                            .textFieldStyle(.plain)
//                        Spacer()
//                            .frame(height: 20)
//                        LabelField(fetch: fetch, labels: labels, allLabels: [], user: user, workspace: workspace, document: document)
//                    }
//                    .foregroundColor(.primary)
//                }
                HStack() {
                    BlockViewContainer(user: user, workspace: workspace, document: document, blocks: blocks, promptMenuOpen: $promptMenuOpen, editable: false, selectedLink: $selectedLink, focused: $focused) {
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            
        }
        .padding(.trailing, GlobalDimension.toolbarWidth)
    }

    var body: some View {
        HorizontalFlexPreviewView {
            #if os(macOS)
            content
                .padding(GlobalDimension.toolbarWidth + Spacing.spacing1.rawValue)
            #else
            content
                .padding(.top, Spacing.spacing8.rawValue)
            #endif
        }
        .onAppear {
            vm.fetchDocuments(user: user, workspace: workspace)
        }
    }
}
