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
    let allLabelId: UUID
    
    var body: some View {
        ScrollView {
            HStack(spacing: Spacing.spacing0.rawValue) {
                VStack(alignment: .leading) {
                    ForEach(0..<items.count, id: \.self) { i in
                        TreeViewLabel(id: UUID(), label: .constant(items[i].title), color: items[i].color) {
                            ForEach(items[i].subItems!, id: \.id) { subItem in
                                TreeViewSubline(title: subItem.title, selected: selectedSubItem?.document == subItem.id && (selectedSubItem?.label == items[i].id || allLabelId == items[i].id))
                                    .padding(Spacing.spacing1.rawValue)
                                    .onTapGesture {
                                        selectedSubItem = TreeDocumentIdentifier(label: items[i].id, document: subItem.id)
                                    }
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
        TreeView(selectedSubItem: .constant(nil), items: [], allLabelId: UUID())
    }
}
