//
//  TreeViewItem.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

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
    let value: String
    let selected: Bool
}

struct TreeViewItemCell: View {
    @Environment(\.colorScheme) var colorScheme
    let id: String
    let workspaceId: String
    @State var title: String
    @State var selected: Bool
    @State private var editable: Bool = false
    let deleteDocument: (_ workspaceId: String, _ documentId: String) -> ()
    
    @ViewBuilder func textOrTextField() -> some View {
        HStack {
            if editable {
                CheckmarkView()
                    .onTapGesture {
                        editable = false
                    }
                TextField("", text: $title)
            } else {
                BulletView()
                    .padding(TreeViewItemDimensions.rowPadding.rawValue)
                Text(title)
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
    
    @State private var toggle = false
    let id: String
    let title: String
    let addDocument: (String) -> ()
    let deleteDocument: (_ workspaceId: String, _ documentId: String) -> ()
    let deleteWorkspace: (_ id: String) -> ()
    let documents: [Title]
    
    func innerCell(title: Title) -> some View {
        TreeViewItemCell(id: title.id, workspaceId: id, title: title.value, selected: title.selected, deleteDocument: deleteDocument)
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
                    FileIconView()
                        .padding(TreeViewItemDimensions.rowPadding.rawValue)
                    Text(title)
                        .bold()
                        .padding(TreeViewItemDimensions.rowPadding.rawValue)
                }
                .padding(TreeViewItemDimensions.rowPadding.rawValue)
  
            }
            .contextMenu {
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
