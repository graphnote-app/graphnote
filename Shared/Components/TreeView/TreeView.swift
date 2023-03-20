//
//  TreeView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData

struct TreeView: View {
    @EnvironmentObject private var orientationInfo: OrientationInfo

    let documents: [Document]
    var selected: Binding<DocumentIdentifier>
    
    func refresh() {
        
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical, showsIndicators: false) {
                #if os(iOS)
                Spacer()
                    .frame(height: orientationInfo.orientation == .landscape ? 10 : 60)
               
                VStack(alignment: .leading) {
                    ForEach(documents.map {TreeViewItem(id: $0.id.wrappedValue, workspace: $0.workspace, selected: selected, refresh: refresh)}) { item in
                        item
                    }
                }
                .padding()
                #else
                VStack(alignment: .leading) {
                    ForEach(documents.map {TreeViewItem(id: $0, document: $0, selected: selected, refresh: refresh)}) { item in
                        item
                    }
                }
                .padding([.top, .bottom])
                #endif
            }
            Spacer()
            WorkspaceMenu()
        }
    }
}
