//
//  TreeViewItem.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData

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
    let title: Binding<String>
    let id: UUID
    let workspaceId: UUID
    @State var selected: Bool
    @State var editable: Bool
    @FocusState private var focusedField: FocusField?
    let deleteDocument: (_ workspaceId: UUID, _ documentId: UUID) -> ()
    let clearNewIDCallback: () -> ()
    let setSelectedDocument: (_ documentId: UUID, _ workspaceId: UUID) -> ()
    
    init(title: Binding<String>, id: UUID, workspaceId: UUID, selected: Bool, editable: Bool, deleteDocument: @escaping (_ workspaceId: UUID, _ documentId: UUID) -> (), clearNewIDCallback: @escaping () -> (), setSelectedDocument: @escaping (_ documentId: UUID, _ workspaceId: UUID) -> ()) {
        self.title = title
        self.id = id
        self.workspaceId = workspaceId
        self._selected = State(wrappedValue: selected)
        self._editable = State(wrappedValue: editable)
        self.deleteDocument = deleteDocument
        self.clearNewIDCallback = clearNewIDCallback
        self.setSelectedDocument = setSelectedDocument
    }
    
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
                        clearNewIDCallback()
                        
                        setSelectedDocument(id, workspaceId)
                        
                    }
                    .focused($focusedField, equals: .field)
                    .onAppear {
                        print("onAppear")
                        if editable {
                            focusedField = .field
                        }
                    }
                    .onChange(of: title.wrappedValue) { newValue in
                        
                        let entity = NSEntityDescription.entity(forEntityName: "Document", in: moc)
                        let request = NSFetchRequest<NSFetchRequestResult>()
                        request.entity = entity
                        let predicate = NSPredicate(format: "(id = %@)", id.uuidString)
                        request.predicate = predicate
                        if let results = try? moc.fetch(request), let objectUpdate = results.first as? NSManagedObject {
                            objectUpdate.setValue(title, forKey: "title")
                            print(objectUpdate)
                            try? moc.save()
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
        
            if selected {
                self.textOrTextField()
                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
                    .overlay {
                        Rectangle()
                            .foregroundColor(colorScheme == .dark ? Color(red: 0.9, green: 0.9, blue: 0.9, opacity: 0.1) : Color(red: 0.1, green: 0.1, blue: 0.1, opacity: 0.1))
                            .cornerRadius(4)
                    }
                    .contextMenu {
                        Button {
                            editable = true
                            selected = false
                        } label: {
                            Text("Rename")
                        }
                        Button {
                            print("Delete document: \(id)")
                            deleteDocument(workspaceId, id)
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
                            print("Delete document: \(id)")
                            deleteDocument(workspaceId, id)
                        } label: {
                            Text("Delete document")
                        }
                    }
            }
        }
    }
}

struct TreeViewItem: View, Identifiable {
    @EnvironmentObject var treeViewModel: TreeViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    @State private var toggle = false
    @FocusState private var focusedField: FocusField?
    @State var editable: Bool
    @StateObject private var workspaces = WorkspacesModel()
    var newDocumentId: UUID?
    let id: UUID
    @State var title: String
    let addDocument: (UUID) -> ()
    let deleteDocument: (_ workspaceId: UUID, _ documentId: UUID) -> ()
    let deleteWorkspace: (_ id: UUID) -> ()
    let clearNewIDCallback: () -> ()
    let setSelectedDocument: (_ documentId: UUID, _ workspaceId: UUID) -> ()
    @State var selected: SelectedDocument
    
    init(editable: Bool, newDocumentId: UUID?, id: UUID, title: String, addDocument: @escaping (UUID) -> (), deleteDocument: @escaping (_ workspaceId: UUID, _ documentId: UUID) -> (), deleteWorkspace: @escaping (_ id: UUID) -> (), clearNewIDCallback: @escaping () -> (), setSelectedDocument: @escaping (_ documentId: UUID, _ workspaceId: UUID) -> (), selected: SelectedDocument) {
        self._editable = State(initialValue: editable)
        self.newDocumentId = newDocumentId
        self.id = id
        self._title = State(initialValue: title)
        self.addDocument = addDocument
        self.deleteDocument = deleteDocument
        self.deleteWorkspace = deleteWorkspace
        self.clearNewIDCallback = clearNewIDCallback
        self.setSelectedDocument = setSelectedDocument
        self._selected = State(initialValue: selected)
    }
    
    func innerCell(doc: DocumentModel) -> some View {
        TreeViewItemCell(title: .constant(doc.title), id: doc.id, workspaceId: id, selected: false, editable: doc.id == newDocumentId, deleteDocument: deleteDocument, clearNewIDCallback: clearNewIDCallback, setSelectedDocument: setSelectedDocument)
    }
    
    var documents: [DocumentModel]? {
        return workspaces.items.filter({$0.id == id}).first?.documents.items
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
                        TextField("", text: $title)
                            .onSubmit {
                                editable = false
                                focusedField = nil
                                clearNewIDCallback()
                                
                                if let document = documents?.first {
                                    setSelectedDocument(document.id, id)
                                }
                            }
                            .focused($focusedField, equals: .field)
                            .onAppear {
                                if editable {
                                    focusedField = .field
                                }
                            }
                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
                            .onChange(of: title) { newValue in
                                let entity = NSEntityDescription.entity(forEntityName: "Workspace", in: moc)
                                let request = NSFetchRequest<NSFetchRequestResult>()
                                request.entity = entity
                                let predicate = NSPredicate(format: "(id = %@)", id.uuidString)
                                request.predicate = predicate
                                if let results = try? moc.fetch(request), let objectUpdate = results.first as? NSManagedObject {
                                    objectUpdate.setValue(title, forKey: "title")
                                    print(objectUpdate)
                                    try? moc.save()
                                }
                            }
                    } else {
                        FileIconView()
                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
                        Text(title)
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
                    deleteWorkspace(id)
                } label: {
                    Text("Delete workspace")
                }
            }
            .onTapGesture {
                toggle = !toggle
            }
            .task {
                print(selected)
            }
            .onChange(of: selected) { newValue in
                print(newValue)
            }
        }
        
        
        if toggle {
           
            if let documents = documents {
                VStack(alignment: .leading) {
                    ForEach(0..<documents.count) { index in
                        if documents[index].id == selected.documentId {
                            self.innerCell(doc: documents[index])
                                .onTapGesture {
                                    treeViewModel.closure(self.id, documents[index].id)
                                }
                        } else {
                            self.innerCell(doc: documents[index])
                                .onTapGesture {
                                    treeViewModel.closure(self.id, documents[index].id)
                                }
                        }
                    }
                    TreeViewAddView()
                        .padding(.top, 10)
                        .onTapGesture {
                            addDocument(id)
                        }
                }
                .padding([.leading], 40)
            }
            
        }

    }
}
