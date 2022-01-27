//
//  TreeView.swift
//  Graphnote
//
//  Created by Hayden Pennington on 1/22/22.
//

import SwiftUI

final class TreeViewModel: ObservableObject {
    @Published public var closure: (_ treeViewItemId: String, _ documentId: String) -> ()
    
    init(closure: @escaping (_ treeViewItemId: String, _ documentId: String) -> ()) {
        self.closure = closure
    }
}

struct TreeView: View {
    @EnvironmentObject var orientationInfo: OrientationInfo
    let items: [TreeViewItem]
    let addWorkspace: () -> ()
    let closure: (_ treeViewItemId: String, _ documentId: String) -> ()
    
    var body: some View {
        ZStack {
            EffectView()
            ScrollView(.vertical, showsIndicators: false) {
                #if os(iOS)
                Spacer()
                    .frame(height: orientationInfo.orientation == .landscape ? 10 : 60)
                #else
          
          
                #endif
                VStack(alignment: .leading) {
                    ForEach(items) { item in
                        item.environmentObject(TreeViewModel(closure: closure))
                            
                    }
                    TreeViewAddView()
                        .padding(.top, 20)
                        .onTapGesture {
                            addWorkspace()
                        }
                }
                .padding()
            }
        }
    }
}

//
//struct TreeView_Previews: PreviewProvider {
//    static var previews: some View {
//        let items = [
//            TreeViewItem(id: "123", title: "Kanception", documents: [Title(id: "123", value: "Title 1", selected: false), Title(id: "321", value: "Title 2", selected: false)]),
//            TreeViewItem(id: "234", title: "Graphnote", documents: [Title(id: "123", value: "Title 1", selected: false), Title(id: "321", value: "Title 2", selected: false)]),
//            TreeViewItem(id: "345", title: "SwiftBook", documents: [Title(id: "123", value: "Title 1", selected: true), Title(id: "321", value: "Title 2", selected: false)]),
//        ]
//        TreeView(items: items) { treeViewItem, documentId in
//            
//        }
//    }
//}
