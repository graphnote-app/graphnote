//
//  TreeView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

//final class TreeViewModel: ObservableObject {
//    @Published public var closure: (_ treeViewItemId: UUID, _ documentId: UUID) -> ()
//    
//    init(closure: @escaping (_ treeViewItemId: UUID, _ documentId: UUID) -> ()) {
//        self.closure = closure
//    }
//}

struct TreeView: View {
    @EnvironmentObject var orientationInfo: OrientationInfo
    var workspaces: Workspaces
    
    var body: some View {
        ZStack() {
            EffectView()
            ScrollView(.vertical, showsIndicators: false) {
                #if os(iOS)
                Spacer()
                    .frame(height: orientationInfo.orientation == .landscape ? 10 : 60)
               
                VStack(alignment: .leading) {
//                    ForEach(items) { item in
//                        item.environmentObject(TreeViewModel(closure: closure))
//                    }
                    
                    ForEach(0..<workspaces.count) { index in
                        TreeViewItem(id: workspaces[index].id, title: workspaces[index].title)
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
//                    ForEach(items) { item in
//                        item.environmentObject(TreeViewModel(closure: closure))
//                    }
                    ForEach(0..<workspaces.items.count) { index in
                        TreeViewItem(id: workspaces.items[index].id!, title: .constant(workspaces.items[index].title!))
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
