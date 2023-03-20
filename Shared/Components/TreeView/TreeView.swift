//
//  TreeView.swift
//  Graphnote (macOS)
//
//  Created by Hayden Pennington on 3/19/23.
//

import SwiftUI

struct TreeView: View {
    @Binding var selectedDocument: DocumentIdentifier
    
    var body: some View {
        VStack(alignment: .leading) {
            TreeViewLabel(id: UUID(), selected: $selectedDocument) {
                
            }
        }
        .padding([.top, .bottom])
    }
}

struct TreeView_Previews: PreviewProvider {
    static var previews: some View {
        TreeView(selectedDocument: .constant(DocumentIdentifier(workspaceId: UUID(), documentId: UUID())))
    }
}
