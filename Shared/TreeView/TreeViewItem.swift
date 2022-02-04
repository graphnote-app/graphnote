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

struct Title: Identifiable, Comparable {
    
    static func < (lhs: Title, rhs: Title) -> Bool {
        return lhs.value < rhs.value
    }
    
    let id: String
    var value: String
    let selected: Bool
    let createdAt: Date
}

enum FocusField: Hashable {
   case field
}

struct TreeViewItemCell: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    let id: String
    let workspaceId: String
    var title: Binding<String>
    @State var selected: Bool
    @State var editable: Bool
    @FocusState private var focusedField: FocusField?
    let deleteDocument: (_ workspaceId: String, _ documentId: String) -> ()
    let clearNewIDCallback: () -> ()
    let setSelectedDocument: (_ documentId: String, _ workspaceId: String) -> ()
    
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
                        let predicate = NSPredicate(format: "(id = %@)", id)
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
    var newDocumentId: String
    let id: String
    @State var title: String
    let addDocument: (String) -> ()
    let deleteDocument: (_ workspaceId: String, _ documentId: String) -> ()
    let deleteWorkspace: (_ id: String) -> ()
    let documents: [Title]
    let clearNewIDCallback: () -> ()
    let setSelectedDocument: (_ documentId: String, _ workspaceId: String) -> ()
    
    func innerCell(title: Title) -> some View {
        TreeViewItemCell(id: title.id, workspaceId: id, title: .constant(title.value), selected: title.selected, editable: title.id == newDocumentId, deleteDocument: deleteDocument, clearNewIDCallback: clearNewIDCallback, setSelectedDocument: setSelectedDocument)
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
                                
                                if let document = documents.first {
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
                                let predicate = NSPredicate(format: "(id = %@)", id)
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
        }
        
        
        if toggle {
            VStack(alignment: .leading) {
                ForEach(documents) { title in
                    if title.selected {
                        self.innerCell(title: title)

                            .onTapGesture {
                                treeViewModel.closure(self.id, title.id)
                            }
                    } else {
                        self.innerCell(title: title)
                            .onTapGesture {
                                treeViewModel.closure(self.id, title.id)
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
