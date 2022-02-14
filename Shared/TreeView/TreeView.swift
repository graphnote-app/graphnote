//
//  TreeView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI
import CoreData

struct TreeView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var orientationInfo: OrientationInfo
    @ObservedObject private var viewModel: TreeViewViewModel

    var selectedDocument: UUID
    let onSelectionChange: (_ workspaceId: UUID, _ documentId: UUID) -> ()
    
    init(selectedDocument: UUID, moc: NSManagedObjectContext, onSelectionChange: @escaping (_ workspaceId: UUID, _ documentId: UUID) -> ()) {
        self.selectedDocument = selectedDocument
        self.onSelectionChange = onSelectionChange
        self.viewModel = TreeViewViewModel(moc: moc)
    }

    var body: some View {
        ZStack() {
            EffectView()
            ScrollView(.vertical, showsIndicators: false) {
                #if os(iOS)
                Spacer()
                    .frame(height: orientationInfo.orientation == .landscape ? 10 : 60)
               
                VStack(alignment: .leading) {
                    ForEach($viewModel.workspaces.map {TreeViewItem(moc: moc, id: $0.id.wrappedValue, workspace: $0, selectedDocument: selectedDocument, onSelectionChange: onSelectionChange)}) { item in
                        item.environmentObject(TreeViewViewModel(moc: self.moc))
                    }
                    TreeViewAddView()
                        .padding(.top, 20)
                        .onTapGesture {
//                            addWorkspace()
                        }
                }
                .padding()
                #else
                VStack(alignment: .leading) {
                    ForEach($viewModel.workspaces.map {TreeViewItem(moc: moc, id: $0.id.wrappedValue, workspace: $0, selectedDocument: selectedDocument, onSelectionChange: onSelectionChange)}) { item in
                        item.environmentObject(TreeViewViewModel(moc: self.moc))
                    }
                    TreeViewAddView()
                        .padding(.top, 20)
                        .onTapGesture {
//                            addWorkspace()
                        }
                }
                .padding([.top, .bottom])
                #endif
            }
        }
    }
}
