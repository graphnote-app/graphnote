//
//  TreeView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct TreeView: View {
    @Binding var selectedSubItem: TreeDocumentIdentifier?
    var items: [TreeViewItem]
    
    var body: some View {
        ScrollView {
            HStack(spacing: Spacing.spacing0.rawValue) {
                VStack(alignment: .leading) {
                    ForEach(items, id: \.id) { item in
                        TreeViewLabel(id: UUID(), label: .constant(item.title), color: item.color) {
                            if let subItems = item.subItems {
                                return ForEach(subItems, id: \.id) { subItem in
                                    TreeViewSubline(title: subItem.title, selected: selectedSubItem?.document == subItem.id && selectedSubItem?.label == item.id)
                                        .onTapGesture {
                                            selectedSubItem = TreeDocumentIdentifier(label: item.id, document: subItem.id)
                                        }
                                }
                            } else {
                                return EmptyView()
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        .padding([.top, .bottom])
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        TreeView(selectedSubItem: .constant(nil), items: [])
    }
}
