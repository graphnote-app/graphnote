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
    case arrowWidthHeight = 12
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
    var selectedDocument: Binding<UUID>
    var selectedWorkspace: Binding<UUID>
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
                        
//                        clearNewIDCallback()

//                        setSelectedDocument(id, workspaceId)

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
        
            if selectedDocument.wrappedValue == self.documentId && selectedWorkspace.wrappedValue == self.workspaceId {
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
//                            deleteDocument(workspaceId, id)
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
//                            deleteDocument(workspaceId, id)
                        } label: {
                            Text("Delete document")
                        }
                    }
                    
            }
        }
        .onTapGesture {
            selectedWorkspace.wrappedValue = workspaceId
            selectedDocument.wrappedValue = documentId
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
    var selectedDocument: Binding<UUID>
    var selectedWorkspace: Binding<UUID>
//    let onSelectionChange: (_ workspaceId: UUID, _ documentId: UUID) -> ()
    
    @ObservedObject private var viewModel: TreeViewItemViewModel
    
    init(moc: NSManagedObjectContext, id: UUID, workspace: Binding<Workspace>, selectedDocument: Binding<UUID>, selectedWorkspace: Binding<UUID>) {
        self.moc = moc
        self.id = id

        self.workspace = workspace
        self.selectedDocument = selectedDocument
        self.selectedWorkspace = selectedWorkspace
        self.viewModel = TreeViewItemViewModel(moc: moc, workspaceId: id)
        
        print(viewModel.documents.count)
        
    }

    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                EffectView()
                HStack {
                    if toggle {
                        Arrow()
                            .frame(width: TreeViewItemDimensions.arrowWidthHeight.rawValue, height: TreeViewItemDimensions.arrowWidthHeight.rawValue)
                            .foregroundColor(color)
                            .rotationEffect(Angle(degrees: 90))
                    } else {
                        Arrow()
                            .frame(width: TreeViewItemDimensions.arrowWidthHeight.rawValue, height: TreeViewItemDimensions.arrowWidthHeight.rawValue)
                            .foregroundColor(color)
                    }
                    
                    
                    if editable {
                        CheckmarkView()
                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
                            .onTapGesture {
                                editable = false
                            }
                        TextField("", text: workspace.title)
                            .onSubmit {
                                editable = false
                                focusedField = nil
//                                clearNewIDCallback()
//
//                                if let document = documents?.first {
//                                    setSelectedDocument(document.id, id)
//                                }
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
//                    deleteWorkspace(id)
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
                        TreeViewItemCell(title: $viewModel.documents[index].title, documentId: viewModel.documents[index].id, workspaceId: viewModel.documents[index].workspace.id, selectedDocument: selectedDocument, selectedWorkspace: selectedWorkspace)
                    }
                }
                
                TreeViewAddView()
                    .padding(.top, 10)
                    .onTapGesture {
//                            addDocument(id)
                    }
            }
            .padding([.leading], 40)
        }

    }
    
}
