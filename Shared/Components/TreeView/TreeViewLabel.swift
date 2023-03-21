//
//  TreeViewLabel.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData
import Combine

enum TreeViewLabelDimensions: CGFloat {
    case arrowWidthHeight = 16
    case rowPadding = 4
}

enum FocusField: Hashable {
   case field
}

struct TreeViewLabel: View, Identifiable {
    @Environment(\.colorScheme) private var colorScheme
//    @Environment(\.managedObjectContext) private var moc
    
    @State private var toggle = false
    @State private var editable = false
    @FocusState private var focusedField: FocusField?
    
    let id: UUID
//    let document: Binding<Document>
//    var selected: Binding<DocumentIdentifier>
    @Binding var label: String
    let color: Color
    let refresh: () -> ()
    let content: () -> any View
    
//    @ObservedObject private var viewModel: TreeViewItemViewModel
//
//    init(id: UUID,
////         document: Binding<Document>,
//         label: Binding<String>,
//         refresh: @escaping () -> ()
//    ) {
//        self.id = id
////        self.document = document
//        self.label =
//        self.refresh = refresh
////        self.viewModel = TreeViewItemViewModel(moc: moc, workspaceId: id)
//    }
    
    func refreshDocuments() {
//        self.viewModel.fetchDocuments(workspaceId: self.document.workspace.id.wrappedValue)
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if toggle {
                    ArrowView(color: color)
                        .frame(width: TreeViewLabelDimensions.arrowWidthHeight.rawValue, height: TreeViewLabelDimensions.arrowWidthHeight.rawValue)
                        .rotationEffect(Angle(degrees: 90))
                
                } else {
                    ArrowView(color: color)
                        .frame(width: TreeViewLabelDimensions.arrowWidthHeight.rawValue, height: TreeViewLabelDimensions.arrowWidthHeight.rawValue)
                }
                
                
                if editable {
                    CheckmarkView()
                        .contentShape(Rectangle())
                        .padding(TreeViewLabelDimensions.rowPadding.rawValue)
                        .onTapGesture {
                            editable = false
                        }
                    TextField("", text: $label)
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
                        .padding(TreeViewLabelDimensions.rowPadding.rawValue)
                        
                } else {
                    FileIconView()
                        .foregroundColor(color)
                        .padding(TreeViewLabelDimensions.rowPadding.rawValue)
                    Text(label)
                        .bold()
                        .padding(TreeViewLabelDimensions.rowPadding.rawValue)
                }
                
            }
            .padding(TreeViewLabelDimensions.rowPadding.rawValue)
            .contextMenu {
                Button {
                    editable = true
                } label: {
                    Text("Rename workspace")
                }
                Button {
                    print("Delete workspace \(id)")
//                    viewModel.deleteWorkspace(workspaceId: id)
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
                AnyView(content())
//                if let _ = viewModel.documents {
//                    ForEach(0..<viewModel.documents.count, id: \.self) { index in
//                        TreeViewSubItem(title: $viewModel.documents[index].title, documentId: viewModel.documents[index].id, workspaceId: viewModel.documents[index].workspace.id, selected: selected, deleteDocument: viewModel.deleteDocument, refresh: refreshDocuments)
//                    }
//                }
//
//                TreeViewAddView()
//                    .padding(.top, 10)
//                    .onTapGesture {
//                        if let newDocumentId = viewModel.addDocument(workspaceId: id) {
//                            selected.wrappedValue = DocumentIdentifier(workspaceId: document.workspace.id.wrappedValue, documentId: newDocumentId)
//                        }
//                    }
            }
            .padding([.leading], 40)
        }

    }
    
}
