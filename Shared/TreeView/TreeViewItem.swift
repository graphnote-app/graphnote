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
    let title: String
    let id: UUID
    let workspaceId: UUID
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
        }.task {
            
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
    }
}

struct TreeViewItem: View, Identifiable {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    
    @State private var toggle = false
    @FocusState private var focusedField: FocusField?
    @StateObject private var allDocuments = Documents()

    let id: UUID
    var title: Binding<String>

    init(id: UUID, title: Binding<String>) {
        self.id = id
        self.title = title
    }
    
    var documents: [DocumentObjectModel] {
        return allDocuments.items.filter({$0.workspaceId == self.id})
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
                    
                    
//                    if editable {
//                        CheckmarkView()
//                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
//                            .onTapGesture {
//                                editable = false
//                            }
//                        TextField("", text: $title)
//                            .onSubmit {
//                                editable = false
//                                focusedField = nil
//                                clearNewIDCallback()
//
//                                if let document = documents?.first {
//                                    setSelectedDocument(document.id, id)
//                                }
//                            }
//                            .focused($focusedField, equals: .field)
//                            .onAppear {
//                                if editable {
//                                    focusedField = .field
//                                }
//                            }
//                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
//                            .onChange(of: title) { newValue in
//                                let entity = NSEntityDescription.entity(forEntityName: "Workspace", in: moc)
//                                let request = NSFetchRequest<NSFetchRequestResult>()
//                                request.entity = entity
//                                let predicate = NSPredicate(format: "(id = %@)", id.uuidString)
//                                request.predicate = predicate
//                                if let results = try? moc.fetch(request), let objectUpdate = results.first as? NSManagedObject {
//                                    objectUpdate.setValue(title, forKey: "title")
//                                    print(objectUpdate)
//                                    try? moc.save()
//                                }
//                            }
//                    } else {
                        FileIconView()
                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
                        Text(title.wrappedValue)
                            .bold()
                            .padding(TreeViewItemDimensions.rowPadding.rawValue)
//                    }
                    
                }
                .padding(TreeViewItemDimensions.rowPadding.rawValue)
  
            }
            .contextMenu {
                Button {
//                    editable = true
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
                toggle = !toggle
            }
            

        }.task {
            allDocuments.fetchDocuments(workspaceId: id)
        }
        
        
        if toggle {
           
            
            VStack(alignment: .leading) {
                ForEach(0..<documents.count) { index in
//                        if documents[index].id == selected.documentId {
//                            TreeViewItem(id: documents[index].id, title: documents[index].title)
//                        } else {
                    TreeViewItemCell(title: documents[index].title, id: documents[index].id, workspaceId: documents[index].workspaceId)
//                        }
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
