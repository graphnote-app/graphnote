//
//  TreeViewSubItem.swift
//  Graphnote
//
//  Created by Hayden Pennington on 2/20/22.
//

import SwiftUI

struct TreeViewSubItem: View {
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
