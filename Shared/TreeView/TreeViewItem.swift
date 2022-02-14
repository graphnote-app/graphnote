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
    let title: String
    let id: UUID
    let workspaceId: UUID
    let onSelectionChange: (_ workspaceId: UUID, _ documentId: UUID) -> ()
//    @State var selected: Bool
//    @State var editable: Bool
    @FocusState private var focusedField: FocusField?
//    let deleteDocument: (_ workspaceId: UUID, _ documentId: UUID) -> ()
//    let clearNewIDCallback: () -> ()
//    let setSelectedDocument: (_ documentId: UUID, _ workspaceId: UUID) -> ()
//
//    init(title: Binding<String>, id: UUID, workspaceId: UUID, selected: Bool, editable: Bool, deleteDocument: @escaping (_ workspaceId: UUID, _ documentId: UUID) -> (), clearNewIDCallback: @escaping () -> (), setSelectedDocument: @escaping (_ documentId: UUID, _ workspaceId: UUID) -> ()) {
//        self.title = title
//        self.id = id
//        self.workspaceId = workspaceId
//        self._selected = State(wrappedValue: selected)
//        self._editable = State(wrappedValue: editable)
//        self.deleteDocument = deleteDocument
//        self.clearNewIDCallback = clearNewIDCallback
//        self.setSelectedDocument = setSelectedDocument
//    }
    
    @ViewBuilder func textOrTextField() -> some View {
        HStack {
//            if editable {
//                CheckmarkView()
//                    .onTapGesture {
//                       editable = false
//                    }
//                TextField("", text: title)
//                    .onSubmit {
//                        editable = false
//                        focusedField = nil
//                        clearNewIDCallback()
//
//                        setSelectedDocument(id, workspaceId)
//
//                    }
//                    .focused($focusedField, equals: .field)
//                    .onAppear {
//                        print("onAppear")
//                        if editable {
//                            focusedField = .field
//                        }
//                    }
//                    .onChange(of: title.wrappedValue) { newValue in
//
//                        let entity = NSEntityDescription.entity(forEntityName: "Document", in: moc)
//                        let request = NSFetchRequest<NSFetchRequestResult>()
//                        request.entity = entity
//                        let predicate = NSPredicate(format: "(id = %@)", id.uuidString)
//                        request.predicate = predicate
//                        if let results = try? moc.fetch(request), let objectUpdate = results.first as? NSManagedObject {
//                            objectUpdate.setValue(title, forKey: "title")
//                            print(objectUpdate)
//                            try? moc.save()
//                        }
//                    }
//            } else {
                BulletView()
                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
                HStack {
                    Text(title)

                    Spacer()
                }.frame(width: 130)
//            }
        }
    }

    var body: some View {
        ZStack(alignment: .leading) {
            EffectView()
        
//            if selected {
//                self.textOrTextField()
//                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
//                    .overlay {
//                        Rectangle()
//                            .foregroundColor(colorScheme == .dark ? Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 0.1) : Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.1))
//                            .cornerRadius(4)
//                    }
//                    .contextMenu {
//                        Button {
//                            editable = true
//                            selected = false
//                        } label: {
//                            Text("Rename")
//                        }
//                        Button {
//                            print("Delete document: \(id)")
//                            deleteDocument(workspaceId, id)
//                        } label: {
//                            Text("Delete document")
//                        }
//                    }
//            } else {
                self.textOrTextField()
                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
                    .contextMenu {
                        Button {
//                            editable = true
                        } label: {
                            Text("Rename")
                        }
                        Button {
                            print("Delete document: \(id)")
//                            deleteDocument(workspaceId, id)
                        } label: {
                            Text("Delete document")
                        }
                    }
//            }
        }
        .onTapGesture {
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
    var selectedDocument: UUID
    let onSelectionChange: (_ workspaceId: UUID, _ documentId: UUID) -> ()
    
    @ObservedObject private var viewModel: TreeViewItemViewModel
    
    init(moc: NSManagedObjectContext, id: UUID, workspace: Binding<Workspace>, selectedDocument: UUID, onSelectionChange: @escaping (_ workspaceId: UUID, _ documentId: UUID) -> ()) {
        self.moc = moc
        self.id = id

        self.workspace = workspace
        self.selectedDocument = selectedDocument
        self.onSelectionChange = onSelectionChange
        self.viewModel = TreeViewItemViewModel(moc: moc, workspaceId: id)
        
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
                if let documents = viewModel.documents {
                    ForEach(0..<documents.count) { index in
    //                        if documents[index].id == selected.documentId {
    //                            TreeViewItem(id: documents[index].id, title: documents[index].title)
    //                        } else {
                        TreeViewItemCell(title: documents[index].title, id: documents[index].id, workspaceId: documents[index].workspace.id, onSelectionChange: onSelectionChange)
    //                        }
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
