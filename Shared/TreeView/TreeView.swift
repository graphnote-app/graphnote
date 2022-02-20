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

    var selected: Binding<DocumentIdentifier>
    
    init(selected: Binding<DocumentIdentifier>, moc: NSManagedObjectContext) {
        self.selected = selected
        self.viewModel = TreeViewViewModel(moc: moc)
    }
    
    func refresh() -> () {
        self.viewModel.fetchWorkspaces()
    }

    var body: some View {
        ZStack() {
            EffectView()
            ScrollView(.vertical, showsIndicators: false) {
                #if os(iOS)
                Spacer()
                    .frame(height: orientationInfo.orientation == .landscape ? 10 : 60)
               
                VStack(alignment: .leading) {
                    ForEach($viewModel.workspaces.map {TreeViewItem(moc: moc, id: $0.id.wrappedValue, workspace: $0, selected: selected, refresh: refresh)}) { item in
                        item.environmentObject(TreeViewViewModel(moc: self.moc))
                    }
                    TreeViewAddView()
                        .padding(.top, 20)
                        .onTapGesture {
                            viewModel.addWorkspace()
                        }
                }
                .padding()
                #else
                VStack(alignment: .leading) {
                    ForEach($viewModel.workspaces.map {TreeViewItem(moc: moc, id: $0.id.wrappedValue, workspace: $0, selected: selected, refresh: refresh)}) { item in
                        item.environmentObject(TreeViewViewModel(moc: self.moc))
                    }
                    TreeViewAddView()
                        .padding(.top, 20)
                        .onTapGesture {
                            viewModel.addWorkspace()
                        }
                }
                .padding([.top, .bottom])
                #endif
            }
        }
    }
}
