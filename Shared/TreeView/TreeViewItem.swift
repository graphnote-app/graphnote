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

struct TreeViewItemCell: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    var title: Binding<String>
    let documentId: UUID
    let workspaceId: UUID
    var selected: Binding<DocumentIdentifier>
    let deleteDocument: (UUID, UUID) -> ()
    let refresh: () -> ()
    @State var editable = false
    @FocusState private var focusedField: FocusField?

    @ViewBuilder func textOrTextField() -> some View {
        HStack {
            if editable {
                CheckmarkView()
                    .onTapGesture {
                       editable = false
                    }
                TextField("", text: title)
                    .onSubmit {
                        editable = false
                        focusedField = nil
                    }
                    .focused($focusedField, equals: .field)
                    .onAppear {
                        print("onAppear")
                        if editable {
                            focusedField = .field
                        }
                    }
            } else {
                BulletView()
                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
                HStack {
                    Text(title.wrappedValue)

                    Spacer()
                }.frame(width: 130)
            }
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            EffectView()
        
//            if selected.documentId == self.documentId && selected.workspaceId == self.workspaceId {
            if selected.wrappedValue == DocumentIdentifier(workspaceId: self.workspaceId, documentId: self.documentId) {
                
                self.textOrTextField()
                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
                    .background (
                        colorScheme == .dark ? Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 0.1) : Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.1)
                    )
                    .cornerRadius(4)
                    .contextMenu {
                        Button {
                            editable = true
                        } label: {
                            Text("Rename")
                        }
                        Button {
                            print("Delete document: \(documentId)")
                            deleteDocument(workspaceId, documentId)
                            refresh()
                        } label: {
                            Text("Delete document")
                        }
                    }
            } else {
                self.textOrTextField()
                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
                    .contextMenu {
                        Button {
                            editable = true
                        } label: {
                            Text("Rename")
                        }
                        Button {
                            print("Delete document: \(documentId)")
                            deleteDocument(workspaceId, documentId)
                            refresh()
                        } label: {
                            Text("Delete document")
                        }
                    }
                    
            }
        }
        .onTapGesture {
            selected.wrappedValue = DocumentIdentifier(workspaceId: workspaceId, documentId: documentId)
        }
    }
}

struct TreeViewItem: View, Identifiable {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var toggle = false
    @State private var editable = false
    @FocusState private var focusedField: FocusField?
    let moc: NSManagedObjectContext
    let id: UUID

    let workspace: Binding<Workspace>
    var selected: Binding<DocumentIdentifier>
    let refresh: () -> ()
    
    @ObservedObject private var viewModel: TreeViewItemViewModel
    
    init(moc: NSManagedObjectContext,
         id: UUID,
         workspace: Binding<Workspace>,
         selected: Binding<DocumentIdentifier>,
         refresh: @escaping () -> ()
    ) {
        self.moc = moc
        self.id = id

        self.workspace = workspace
        self.selected = selected
        self.refresh = refresh
        self.viewModel = TreeViewItemViewModel(moc: moc, workspaceId: id)
    }
    
    func refreshDocuments() {
        self.viewModel.fetchDocuments(workspaceId: self.workspace.id.wrappedValue)
    }

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                EffectView()
                HStack {
                    if toggle {
                        ArrowView(color: color)
                            .frame(width: TreeViewItemDimensions.arrowWidthHeight.rawValue, height: TreeViewItemDimensions.arrowWidthHeight.rawValue)
                            .rotationEffect(Angle(degrees: 90))
                            .onTapGesture {
                                toggle.toggle()
                            }
                    
                    } else {
                        ArrowView(color: color)
                            .frame(width: TreeViewItemDimensions.arrowWidthHeight.rawValue, height: TreeViewItemDimensions.arrowWidthHeight.rawValue)
                            .onTapGesture {
                                toggle.toggle()
                            }
                    }
                    
                    
                    if editable {
                        CheckmarkView()
                            .contentShape(Rectangle())
                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
                            .onTapGesture {
                                editable = false
                            }
                        TextField("", text: workspace.title)
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
                        Text(workspace.title.wrappedValue)
                            .bold()
                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
                    }
                    
                }
                .padding(TreeViewItemDimensions.rowPadding.rawValue)
  
            }
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
            

            

        }
        
        if toggle {
           
            VStack(alignment: .leading) {
                if let _ = viewModel.documents {
                    ForEach(0..<viewModel.documents.count, id: \.self) { index in
                        TreeViewItemCell(title: $viewModel.documents[index].title, documentId: viewModel.documents[index].id, workspaceId: viewModel.documents[index].workspace.id, selected: selected, deleteDocument: viewModel.deleteDocument, refresh: refreshDocuments)
                    }
                }
                
                TreeViewAddView()
                    .padding(.top, 10)
                    .onTapGesture {
                        if let newDocumentId = viewModel.addDocument(workspaceId: id) {
                            selected.wrappedValue = DocumentIdentifier(workspaceId: workspace.id.wrappedValue, documentId: newDocumentId)
                        }
                    }
            }
            .padding([.leading], 40)
        }

    }
    
}
