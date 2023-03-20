//
//  TreeViewItem.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData
import Combine

enum TreeViewItemDimensions: CGFloat {
    case arrowWidthHeight = 16
    case rowPadding = 4
}

fileprivate let color = Color.gray

enum FocusField: Hashable {
   case field
}

struct TreeViewItem: View, Identifiable {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var moc
    @State private var toggle = false
    @State private var editable = false
    @FocusState private var focusedField: FocusField?
    let id: UUID

    let document: Binding<Document>
    var selected: Binding<DocumentIdentifier>
    let refresh: () -> ()
    
    @ObservedObject private var viewModel: TreeViewItemViewModel
    
    init(id: UUID,
         document: Binding<Document>,
         selected: Binding<DocumentIdentifier>,
         refresh: @escaping () -> ()
    ) {
        self.id = id
        self.document = document
        self.selected = selected
        self.refresh = refresh
        self.viewModel = TreeViewItemViewModel(moc: moc, workspaceId: id)
    }
    
    func refreshDocuments() {
        self.viewModel.fetchDocuments(workspaceId: self.document.workspace.id.wrappedValue)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if toggle {
                    ArrowView(color: color)
                        .frame(width: TreeViewItemDimensions.arrowWidthHeight.rawValue, height: TreeViewItemDimensions.arrowWidthHeight.rawValue)
                        .rotationEffect(Angle(degrees: 90))
                
                } else {
                    ArrowView(color: color)
                        .frame(width: TreeViewItemDimensions.arrowWidthHeight.rawValue, height: TreeViewItemDimensions.arrowWidthHeight.rawValue)
                }
                
                
                if editable {
                    CheckmarkView()
                        .contentShape(Rectangle())
                        .padding(TreeViewItemDimensions.rowPadding.rawValue)
                        .onTapGesture {
                            editable = false
                        }
                    TextField("", text: document.title)
                        .onSubmit {
                            editable = false
                            focusedField = nil
                        }
                        .focused($focusedField, equals: .field)
                        .onAppear {
                            if editable {
                                focusedField = .field
                            }
                        }
                        .padding(TreeViewItemDimensions.rowPadding.rawValue)
                        
                } else {
                    FileIconView()
                        .padding(TreeViewItemDimensions.rowPadding.rawValue)
                    Text(document.title.wrappedValue)
                        .bold()
                        .padding(TreeViewItemDimensions.rowPadding.rawValue)
                }
                
            }
            .padding(TreeViewItemDimensions.rowPadding.rawValue)
            .contextMenu {
                Button {
                    editable = true
                } label: {
                    Text("Rename workspace")
                }
                Button {
                    print("Delete workspace \(id)")
                    viewModel.deleteWorkspace(workspaceId: id)
                    refresh()
                } label: {
                    Text("Delete workspace")
                }
            }
            .onTapGesture {
                toggle.toggle()
            }

        }
        
        if toggle {
           
            VStack(alignment: .leading) {
                if let _ = viewModel.documents {
                    ForEach(0..<viewModel.documents.count, id: \.self) { index in
                        TreeViewSubItem(title: $viewModel.documents[index].title, documentId: viewModel.documents[index].id, workspaceId: viewModel.documents[index].workspace.id, selected: selected, deleteDocument: viewModel.deleteDocument, refresh: refreshDocuments)
                    }
                }
                
                TreeViewAddView()
                    .padding(.top, 10)
                    .onTapGesture {
                        if let newDocumentId = viewModel.addDocument(workspaceId: id) {
                            selected.wrappedValue = DocumentIdentifier(workspaceId: document.workspace.id.wrappedValue, documentId: newDocumentId)
                        }
                    }
            }
            .padding([.leading], 40)
        }

    }
    
}
