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
    @Binding var labels: [Label]
    /// The binding to an array of block model objects.
    @Binding var blocks: [Block]
    
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
    
    @StateObject private var vm = DocumentViewVM()
    @State private var promptText = ""
    private let pad: Double = 30
    
    var content: some View {
        Group {
            VStack(alignment: .center, spacing: pad) {
                HStack() {
                    VStack(alignment: .leading) {
                        TextField("", text: $title)
                            .font(.largeTitle)
                            .textFieldStyle(.plain)
                        Spacer()
                            .frame(height: 20)
                        LabelField(fetch: fetch, labels: $labels, user: user, workspace: workspace, document: document)
                    }
                    .foregroundColor(.primary)
                }
                HStack() {
                    BlockViewContainer(user: user, workspace: workspace, document: document, blocks: $blocks) {
                        fetchBlocks()
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
        .refreshable {
            onRefresh()
        }
    }
}

