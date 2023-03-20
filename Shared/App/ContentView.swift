//
//  ContentView.swift
//  Shared
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData
import SwiftyJSON

fileprivate let documentWidth: CGFloat = 800
fileprivate let treeLayourPriority: CGFloat = 100

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var menuOpen = true
    
    @ObservedObject private var viewModel: ContentViewViewModel
//    @State private var selectedWorkspace: UUID
//    @State private var selectedDocument: UUID
    @State private var selectedIdentifier: DocumentIdentifier
    
    let moc: NSManagedObjectContext

    init(moc: NSManagedObjectContext, initialSelectedDocument: UUID, initalSelectedWorkspace: UUID) {
        self.moc = moc
//        self._selectedDocument = State(initialValue: initialSelectedDocument)
//        self._selectedWorkspace = State(initialValue: initalSelectedWorkspace)
        self._selectedIdentifier = State(initialValue: DocumentIdentifier(workspaceId: initalSelectedWorkspace, documentId: initialSelectedDocument))
        self.viewModel = ContentViewViewModel(moc: moc)
        
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if menuOpen {
                #if os(macOS)
                ZStack() {
                    EffectView()
                    TreeView(selected: $selectedIdentifier, moc: moc)
                        .padding()
                    
                }
                .frame(width: treeWidth)
                .edgesIgnoringSafeArea([.bottom])
                #else
                ZStack() {
                    EffectView()
                    TreeView(selected: $selectedIdentifier, moc: moc)
                    .layoutPriority(treeLayourPriority)
                    
                }
                .frame(width: mobileTreeWidth)
                .edgesIgnoringSafeArea([.top, .bottom])
                .overlay {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            VStack {
                                Spacer()
                                Rectangle()
                                    .background(Color.gray)
                                    .frame(width: 1, height: geometry.size.height * 0.95)
                                Spacer()
                            }
                            
                        }
                    }
                    

                }
                #endif
            }
            if let selectedIdentifier = selectedIdentifier {
                DocumentView(moc: moc, id: selectedIdentifier.documentId, workspaceId: selectedIdentifier.workspaceId, open: $menuOpen)
            }
            
        }.task {

            if let workspace = viewModel.items.sorted().first, let document = (workspace.documents?.allObjects as? [Document])?.first  {
                selectedIdentifier = DocumentIdentifier(workspaceId: workspace.id, documentId: document.id)
            }

        }
        .onChange(of: selectedIdentifier) { newValue in
            viewModel.fetchWorkspaces()
        }
    }
    
    
    
}
